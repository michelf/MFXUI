import Foundation

public protocol MFEditable: UXView {
	associatedtype EditableValue: Equatable
	var editableValue: EditableValue { get set }
	func onEditing(_ callback: @escaping (EditableValue) -> ()) -> Self
}

public struct MFEditableAccessor<EditableValue: Equatable> {
	let get: () -> EditableValue
	let set: (EditableValue) -> ()

	public init(_ get: @escaping @autoclosure () -> EditableValue, with set: @escaping (EditableValue) -> ()) {
		self.get = get
		self.set = set
	}
	public init<Object: AnyObject>(_ keyPath: ReferenceWritableKeyPath<Object, EditableValue>, of object: Object) {
		self.init(object[keyPath: keyPath]) { [weak object] newValue in
			object?[keyPath: keyPath] = newValue
		}
	}

	public func choice(of representedValue: EditableValue) -> MFEditableAccessor<Bool> {
		.init(get() == representedValue) { _ in
			set(representedValue)
		}
	}
}

extension MFEditable {

	public func editing(_ accessor: MFEditableAccessor<EditableValue>) -> Self {
		_ = self.binding(\.editableValue, to: accessor.get(), scheduling: .immediate)
		_ = self.onEditing(accessor.set)
		return self
	}

	public func editing(_ get: @escaping @autoclosure () -> EditableValue, with set: @escaping (EditableValue) -> ()) -> Self {
		_ = self.binding(\.editableValue, to: get(), scheduling: .immediate)
		_ = self.onEditing(set)
		return self
	}

	public func editing<Object: AnyObject>(_ keyPath: ReferenceWritableKeyPath<Object, EditableValue>, of object: Object) -> Self {
		self.editing(object[keyPath: keyPath]) { [weak object] newValue in
			object?[keyPath: keyPath] = newValue
		}
	}

}
