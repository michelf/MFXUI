import Foundation

@propertyWrapper
public struct MFObservable<Value: Equatable> {
	private var _wrappedValue: Value
	private var _changeToken = MFObservableToken()

	public init(wrappedValue initialValue: Value) {
		self._wrappedValue = initialValue
	}

	public var wrappedValue: Value {
		_read {
			assert(Thread.isMainThread)
			_changeToken.didAccess()
			yield _wrappedValue
		}
		set {
			assert(Thread.isMainThread)
			guard wrappedValue != newValue else { return }
			_changeToken.willChange()
			_wrappedValue = newValue
			_changeToken.didChange(updateToken: true)
		}
		_modify {
			// Modify-in-place accessor. can't check for equality in this scenario:
			// 1. we could in theory skip the `didChange`: we'd need to keep a copy of
			//    the old value to be able to do a comparison later, but this is what
			//    we're trying to avoid with this modify accessor.
			// 2. `willChange` needs to be fired before the value is changed,
			//    but it's already too late once we know what the new value is
			assert(Thread.isMainThread)
			_changeToken.didAccess()
			_changeToken.willChange()
			yield &_wrappedValue
			_changeToken.didChange(updateToken: true)
		}
	}

	public var projectedValue: MFObservableToken {
		get { _changeToken }
		set { _changeToken = newValue }
	}
}

@propertyWrapper
public struct MFRawObservable<Value> {
	private var _wrappedValue: Value
	private var _changeToken = MFObservableToken()

	public init(wrappedValue initialValue: Value) {
		self._wrappedValue = initialValue
	}

	public var wrappedValue: Value {
		_read {
			assert(Thread.isMainThread)
			_changeToken.didAccess()
			yield _wrappedValue
		}
		set {
			assert(Thread.isMainThread)
			_changeToken.willChange()
			_wrappedValue = newValue
			_changeToken.didChange(updateToken: true)
		}
		_modify {
			assert(Thread.isMainThread)
			_changeToken.didAccess()
			_changeToken.willChange()
			yield &_wrappedValue
			_changeToken.didChange(updateToken: true)
		}
	}

//	private var wrappedValueNoUpdateToken: Value {
//		_read {
//			assert(Thread.isMainThread)
//			_changeToken.didAccess()
//			yield _wrappedValue
//		}
//		set {
//			assert(Thread.isMainThread)
//			_changeToken.willChange()
//			_wrappedValue = newValue
//			_changeToken.didChange(updateToken: false)
//		}
//		_modify {
//			assert(Thread.isMainThread)
//			_changeToken.didAccess()
//			_changeToken.willChange()
//			yield &_wrappedValue
//			_changeToken.didChange(updateToken: false)
//		}
//	}
//
//	// Access to the wrapped value without updating token when used with a class
//	public static subscript<Object>(
//		_enclosingInstance instance: Object,
//		wrapped wrappedKeyPath: ReferenceWritableKeyPath<Object, Value>,
//		storage storageKeyPath: ReferenceWritableKeyPath<Object, Self>
//	) -> Value {
//		_read {
//			yield instance[keyPath: storageKeyPath].wrappedValueNoUpdateToken
//		}
//		set {
//			instance[keyPath: storageKeyPath].wrappedValueNoUpdateToken = newValue
//		}
//		_modify {
//			yield &instance[keyPath: storageKeyPath].wrappedValueNoUpdateToken
//		}
//	}

	public var projectedValue: MFObservableToken {
		get { _changeToken }
		set { _changeToken = newValue }
	}
}

public struct MFObservableToken {

	public init() {}

	public func didAccess() {
		MFObservatory.didAccess(revision)
	}

	public mutating func willChange() {
		MFObservatory.willChange(revision)
	}
	public mutating func didChange() {
		didChange(updateToken: true)
	}
	fileprivate mutating func didChange(updateToken: Bool) {
		MFObservatory.didChange(revision)
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

public struct MFObservationSet: Hashable {
	fileprivate var revisions: Set<MFObservableToken.Revision> = []

	public var isEmpty: Bool {
		revisions.isEmpty
	}

	public func overlaps(with other: MFObservationSet) -> Bool {
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

	public static func onChange(_ apply: @escaping (MFObservationSet) -> ()) -> AnyObject? {
		NotificationCenter.default.addObserver(forName: MFObservatory.mutationNotificationName, object: nil, queue: nil) { notification in
			assert(Thread.isMainThread)
			if let observationSet = notification.userInfo?[MFObservatory.tokensInfoKey] as? MFObservationSet {
				apply(observationSet)
			}
		}
	}
}

extension MFObservatory {

	fileprivate static var _accessSet: MFObservationSet?
	fileprivate static var _changeSet: MFObservationSet?

	/// Set to true to enable Swift Observation compatibility (experimental).
	static var experimental_usesSwiftObservation = false

	public static func observe(_ apply: () -> ()) -> MFObservationSet {
		var accessSet = MFObservationSet()
		observe(updating: &accessSet, apply)
		return accessSet
	}
	/// Observe accesses during task while updating an old access set.
	static func observe<R>(updating accessSet: inout MFObservationSet, _ apply: () -> R) -> R {
		assert(Thread.isMainThread)
		precondition(!isObserving, "Cannot nest MFObservationTracking observations.")

		// clear old accessSet
		accessSet.revisions.removeAll(keepingCapacity: true)

		_accessSet = MFObservationSet()
		swap(&_accessSet!, &accessSet)
		let result = apply()
		swap(&_accessSet!, &accessSet)
		_accessSet = nil

		return result
	}
	static var isObserving: Bool {
		MFObservatory._accessSet != nil
	}

	fileprivate static func didAccess(_ revision: MFObservableToken.Revision) {
		MFObservatory._accessSet?.revisions.insert(revision)
		if experimental_usesSwiftObservation, #available(macOS 14, iOS 17, tvOS 17, *) {
			observationRegistrar.access(shared, keyPath: \MFObservatory[revision])
		}
	}

	fileprivate static func willChange(_ revision: MFObservableToken.Revision) {
		if experimental_usesSwiftObservation, #available(macOS 14, iOS 17, tvOS 17, *) {
			observationRegistrar.willSet(shared, keyPath: \MFObservatory[revision])
		}
	}

	fileprivate static func didChange(_ revision: MFObservableToken.Revision) {
		if experimental_usesSwiftObservation, #available(macOS 14, iOS 17, tvOS 17, *) {
			observationRegistrar.didSet(shared, keyPath: \MFObservatory[revision])
		}
		if MFObservatory._changeSet == nil {
			setupImplicitObservationTransaction()
		}
		MFObservatory._changeSet!.revisions.insert(revision)
	}

	private static func setupImplicitObservationTransaction() {
		MFObservatory._changeSet = MFObservationSet()
		let runLoopReadyObserver = CFRunLoopObserverCreateWithHandler(nil, CFRunLoopActivity.beforeWaiting.rawValue, false, 0) { observer, activity in
			let changeSet = MFObservatory._changeSet!
			MFObservatory._changeSet = nil
			guard !changeSet.isEmpty else { return }
			NotificationCenter.default.post(name: MFObservatory.mutationNotificationName, object: nil, userInfo: [
				MFObservatory.tokensInfoKey: changeSet
			])
		}
		let runLoop = CFRunLoopGetMain()
		CFRunLoopAddObserver(runLoop, runLoopReadyObserver, .commonModes)
	}

	// Note: keeping these strings under the 15 character threshold to avoid
	// dynamic allocations, thus reducing ARC traffic.
	internal static let mutationNotificationName = Notification.Name("_MFObservMut")
	internal static let tokensInfoKey = "_MFObservToks"

}

// For compatiblity with Swift Observation
public final class MFObservatory: Observable {

	@available(macOS 14, iOS 17, tvOS 17, *)
	static let shared = MFObservatory()

	@available(macOS 14, iOS 17, tvOS 17, *)
	private init() {}

	@available(macOS 14, iOS 17, tvOS 17, *)
	fileprivate static let observationRegistrar = ObservationRegistrar()

	@available(macOS 14, iOS 17, tvOS 17, *)
	fileprivate subscript (_ revision: MFObservableToken.Revision) -> () {
		get { () }
		set { _ = newValue }
	}

}
