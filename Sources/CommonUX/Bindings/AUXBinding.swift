import Foundation

public enum AUXUpdateScheduler {
	case immediate
	case delayed(TimeInterval)
	case throttled(TimeInterval)
}

class AUXBinding: NSObject {

	unowned let view: UXView
	let viewUpdateCallback: (UXView) -> ()
	let scheduling: AUXUpdateScheduler
	var pendingUpdate: Bool = false
	var lastUpdateTime: DispatchTime
	private(set) var observationSet = AUXObservationSet()

	@discardableResult
	fileprivate init?(view: UXView, scheduling: AUXUpdateScheduler, update: @escaping (UXView) -> ()) {
		self.view = view
		self.viewUpdateCallback = update
		self.scheduling = scheduling
		self.lastUpdateTime = .now()
		super.init()
		updateView()
		if observationSet.isEmpty {
			// stale binding: no change can trigger an update
			return nil
		}
		// view retains the binding
		view.auxBindings.append(self)
		// register for changes
		NotificationCenter.default.addObserver(self, selector: #selector(handleOnChangeNotification), name: AUXObservationTracking.mutationNotificationName, object: nil)
	}

	func updateView() {
		AUXObservationTracking.observe(updating: &observationSet) {
			viewUpdateCallback(view)
		}
	}

	@objc private func handleOnChangeNotification(_ notification: Notification) {
		guard let changeSet = notification.userInfo?[AUXObservationTracking.tokensInfoKey] as? AUXObservationSet else { return }
		guard changeSet.overlaps(with: observationSet) else { return }
		scheduleViewUpdate()
	}

	func scheduleViewUpdate() {
		switch scheduling {
		case .immediate:
			// update synchronously
			handleViewUpdate()
			assert(pendingUpdate == false)
		case .delayed(let delay):
			// schedule update after delay
			if pendingUpdate { break }
			pendingUpdate = true
			DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(delay) * 1000)) { [self] in
				pendingUpdate = false
				handleViewUpdate()
			}
		case .throttled(let delay):
			// schedule immediatly but wait if delay between updates is not respected
			if pendingUpdate { break }
			let now = DispatchTime.now()
			let allowedNext = lastUpdateTime + .milliseconds(Int(delay) * 1000)
			if allowedNext <= now {
				// update synchronously
				lastUpdateTime = now
				handleViewUpdate()
				assert(pendingUpdate == false)
			} else {
				// schedule update after delay
				pendingUpdate = true
				DispatchQueue.main.asyncAfter(deadline: allowedNext) { [self] in
					lastUpdateTime = .now()
					pendingUpdate = false
					handleViewUpdate()
				}
			}
		}
	}

	func handleViewUpdate() {
		updateView()
		if observationSet.isEmpty {
			// stale binding: no change can trigger an update anymore
			NotificationCenter.default.removeObserver(self)
		}
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}

}


extension NSObjectProtocol where Self: UXView {

	public func binding<T>(_ keyPath: ReferenceWritableKeyPath<Self, T>, to get: @escaping @autoclosure () -> T, scheduling: AUXUpdateScheduler = .immediate) -> Self {
		binding(scheduling: scheduling) {
			$0[keyPath: keyPath] = get()
		}
	}

	public func binding(scheduling: AUXUpdateScheduler = .immediate, update: @escaping (Self) -> ()) -> Self {
		AUXBinding(view: self, scheduling: scheduling) { view in
			update(view as! Self)
		}
		return self
	}

}

extension UXView {

	private static var auxBindingsAssociatedObjectID : UInt8 = 0

	var auxBindings: [AUXBinding] {
		set {
			objc_setAssociatedObject(self, &UXView.auxBindingsAssociatedObjectID, newValue as NSArray,
									 objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
		}
		get {
			objc_getAssociatedObject(self, &UXView.auxBindingsAssociatedObjectID) as! [AUXBinding]? ?? []
		}
	}

}


private func bindingTest() {
	class M {
		@AUXObservable var name: String = ""
		@AUXObservable var shouldBeHidden: Bool = false
	}
	let m = M()
	let view = UXTextField()
		.binding(\.text, to: m.name)
	let view3 = UXTextField()
		.binding { $0.text = m.name }
}
