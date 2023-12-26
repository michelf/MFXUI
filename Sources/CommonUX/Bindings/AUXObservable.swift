import Foundation

@propertyWrapper
public struct AUXObservable<Value: Equatable> {
	private var _wrappedValue: Value
	private var _changeToken = AUXObservableToken()

	public init(wrappedValue initialValue: Value) {
		self._wrappedValue = initialValue
	}

	public var wrappedValue: Value {
		get {
			assert(Thread.isMainThread)
			_changeToken.didAccess()
			return _wrappedValue
		}
		set {
			setWrappedValue(newValue)
		}
	}

	// Access to the wrapped value without updating token when used with a class
//	public static subscript<Object>(
//		_enclosingInstance instance: Object,
//		wrapped wrappedKeyPath: ReferenceWritableKeyPath<Object, Value>,
//		storage storageKeyPath: ReferenceWritableKeyPath<Object, Self>
//	) -> Value {
//		get { instance[keyPath: storageKeyPath].wrappedValue }
//		set { instance[keyPath: storageKeyPath].setWrappedValue(newValue, updateToken: false) }
//	}

	private mutating func setWrappedValue(_ newValue: Value, updateToken: Bool = true) {
		assert(Thread.isMainThread)
		guard wrappedValue != newValue else { return }
		_changeToken.willChange()
		_wrappedValue = newValue
		_changeToken.didChange(updateToken: updateToken)
	}

	public var projectedValue: AUXObservableToken {
		get { _changeToken }
		set { _changeToken = newValue }
		_modify { yield &_changeToken }
	}
}

@propertyWrapper
public struct AUXRawObservable<Value> {
	private var _wrappedValue: Value
	private var _changeToken = AUXObservableToken()

	public init(wrappedValue initialValue: Value) {
		self._wrappedValue = initialValue
	}

	public var wrappedValue: Value {
		get {
			assert(Thread.isMainThread)
			_changeToken.didAccess()
			return _wrappedValue
		}
		set {
			setWrappedValue(newValue)
		}
	}

	// Access to the wrapped value without updating token when used with a class
//	public static subscript<Object>(
//		_enclosingInstance instance: Object,
//		wrapped wrappedKeyPath: ReferenceWritableKeyPath<Object, Value>,
//		storage storageKeyPath: ReferenceWritableKeyPath<Object, Self>
//	) -> Value {
//		get { instance[keyPath: storageKeyPath].wrappedValue }
//		set { instance[keyPath: storageKeyPath].setWrappedValue(newValue, updateToken: false) }
//	}

	private mutating func setWrappedValue(_ newValue: Value, updateToken: Bool = true) {
		assert(Thread.isMainThread)
		_changeToken.willChange()
		_wrappedValue = newValue
		_changeToken.didChange(updateToken: updateToken)
	}

	public var projectedValue: AUXObservableToken {
		get { _changeToken }
		set { _changeToken = newValue }
		_modify { yield &_changeToken }
	}
}

public struct AUXObservableToken {

	public init() {}

	public func didAccess() {
		AUXObservatory.didAccess(revision)
	}

	public mutating func willChange() {
		AUXObservatory.willChange(revision)
	}
	public mutating func didChange() {
		didChange(updateToken: true)
	}
	fileprivate mutating func didChange(updateToken: Bool) {
		AUXObservatory.didChange(revision)
		if updateToken {
			revision = Self.nextRevision()
		}
	}

	fileprivate typealias Revision = Int64
	fileprivate var revision = Self.nextRevision()

	private mutating func renew() {
		revision = Self.nextRevision()
	}

	fileprivate static func nextRevision() -> Revision {
		assert(Thread.isMainThread)
		_lastRevision &+= 1
		return _lastRevision
	}

	fileprivate static var _lastRevision: Revision = 0
}

public struct AUXObservationSet: Hashable {
	fileprivate var revisions: Set<AUXObservableToken.Revision> = []

	public var isEmpty: Bool {
		revisions.isEmpty
	}

	public func overlaps(with other: AUXObservationSet) -> Bool {
		!revisions.isDisjoint(with: other.revisions)
	}

	public func onChange(_ apply: @escaping () -> ()) -> AnyObject? {
		assert(Thread.isMainThread)
		guard !isEmpty else { return nil }

		return Self.onChange { changes in
			if self.overlaps(with: changes) {
				apply()
			}
		}
	}

	public static func onChange(_ apply: @escaping (AUXObservationSet) -> ()) -> AnyObject? {
		NotificationCenter.default.addObserver(forName: AUXObservatory.mutationNotificationName, object: nil, queue: nil) { notification in
			assert(Thread.isMainThread)
			if let observationSet = notification.userInfo?[AUXObservatory.tokensInfoKey] as? AUXObservationSet {
				apply(observationSet)
			}
		}
	}
}

extension AUXObservatory {

	fileprivate static var _accessSet: AUXObservationSet?
	fileprivate static var _changeSet: AUXObservationSet?

	static var experimental_usesSwiftObservation = false

	public static func observe(_ apply: () -> ()) -> AUXObservationSet {
		var accessSet = AUXObservationSet()
		observe(updating: &accessSet, apply)
		return accessSet
	}
	/// Observe accesses during task while updating an old access set.
	static func observe<R>(updating accessSet: inout AUXObservationSet, _ apply: () -> R) -> R {
		assert(Thread.isMainThread)
		precondition(!isObserving, "Cannot nest AUXObservationTracking observations.")

		// clear old accessSet
		accessSet.revisions.removeAll(keepingCapacity: true)

		_accessSet = AUXObservationSet()
		swap(&_accessSet!, &accessSet)
		let result = apply()
		swap(&_accessSet!, &accessSet)
		_accessSet = nil

		return result
	}
	static var isObserving: Bool {
		AUXObservatory._accessSet != nil
	}

	fileprivate static func didAccess(_ revision: AUXObservableToken.Revision) {
		AUXObservatory._accessSet?.revisions.insert(revision)
		if experimental_usesSwiftObservation, #available(macOS 14, iOS 17, tvOS 17, *) {
			observationRegistrar.access(shared, keyPath: \AUXObservatory[revision])
		}
	}

	fileprivate static func willChange(_ revision: AUXObservableToken.Revision) {
		if experimental_usesSwiftObservation, #available(macOS 14, iOS 17, tvOS 17, *) {
			observationRegistrar.willSet(shared, keyPath: \AUXObservatory[revision])
		}
	}

	fileprivate static func didChange(_ revision: AUXObservableToken.Revision) {
		if experimental_usesSwiftObservation, #available(macOS 14, iOS 17, tvOS 17, *) {
			observationRegistrar.didSet(shared, keyPath: \AUXObservatory[revision])
		}
		if AUXObservatory._changeSet == nil {
			setupImplicitObservationTransaction()
		}
		AUXObservatory._changeSet!.revisions.insert(revision)
	}

	private static func setupImplicitObservationTransaction() {
		AUXObservatory._changeSet = AUXObservationSet()
		let runLoopReadyObserver = CFRunLoopObserverCreateWithHandler(nil, CFRunLoopActivity.beforeWaiting.rawValue, false, 0) { observer, activity in
			let changeSet = AUXObservatory._changeSet!
			AUXObservatory._changeSet = nil
			guard !changeSet.isEmpty else { return }
			NotificationCenter.default.post(name: AUXObservatory.mutationNotificationName, object: nil, userInfo: [
				AUXObservatory.tokensInfoKey: changeSet
			])
		}
		let runLoop = CFRunLoopGetMain()
		CFRunLoopAddObserver(runLoop, runLoopReadyObserver, .commonModes)
	}

	internal static let mutationNotificationName = Notification.Name("_AUXObserveMut")
	internal static let tokensInfoKey = "_AUXChTokens"

}

public final class AUXObservatory: Observable {

	@available(macOS 14, iOS 17, tvOS 17, *)
	static let shared = AUXObservatory()

	@available(macOS 14, iOS 17, tvOS 17, *)
	private init() {}

	@available(macOS 14, iOS 17, tvOS 17, *)
	fileprivate static let observationRegistrar = ObservationRegistrar()

	@available(macOS 14, iOS 17, tvOS 17, *)
	fileprivate subscript (_ revision: AUXObservableToken.Revision) -> () {
		get { () }
		set { _ = newValue }
	}

}
