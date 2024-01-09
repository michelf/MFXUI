import UXKit
#if os(macOS)
import AppKit
#else
import UIKit
#endif

#if os(macOS) || os(tvOS) || os(iOS)
//@available(iOS, deprecated: 14)
@available(tvOS, deprecated: 14)
@usableFromInline
internal final class MFActionHandler: NSObject {

	@usableFromInline
	var onClickCallback: ((AnyObject) -> ())?
	@usableFromInline
	@IBAction func onClick(_ sender: AnyObject) {
		onClickCallback?(sender)
	}

	@usableFromInline
	var onDoubleClickCallback: ((AnyObject) -> ())?
	@usableFromInline
	@IBAction func onDoubleClick(_ sender: AnyObject) {
		onDoubleClickCallback?(sender)
	}

	@usableFromInline
	var onChangeCallback: ((AnyObject) -> ())?
	@usableFromInline
	@IBAction func onChange(_ sender: AnyObject) {
		onChangeCallback?(sender)
	}

	@usableFromInline
	internal static var _associatedValueKey: Int8 = 0

}
#if os(macOS)
extension MFActionHandler: NSTextFieldDelegate {
	@usableFromInline
	@objc func controlTextDidChange(_ obj: Notification) {
		onChangeCallback?(obj.object as AnyObject)
	}
}
#endif

extension NSObjectProtocol where Self: NSObject {

	@usableFromInline
	var auxActionHandler: MFActionHandler {
		if let handler = objc_getAssociatedObject(self, &MFActionHandler._associatedValueKey) as! MFActionHandler? {
			return handler
		} else {
			let handler = MFActionHandler()
			objc_setAssociatedObject(self, &MFActionHandler._associatedValueKey, handler, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
			return handler
		}
	}

}
#endif

public extension NSObjectProtocol where Self: UXButton {

	@inlinable
	@discardableResult
	func onClick(_ callback: @escaping (Self) -> ()) -> Self {
#if !os(macOS)
		if #available(iOS 14, tvOS 14, *) {
			addAction(UIAction { [unowned self] _ in callback(self) }, for: .touchUpInside)
			return self
		}
#endif
		let handler = auxActionHandler
		handler.onClickCallback = { callback($0 as! Self) }
		return onClick(handler, #selector(MFActionHandler.onClick))
	}

}

public extension NSObjectProtocol where Self: UXTextField {

	@inlinable
	@discardableResult
	func onChange(_ callback: @escaping (Self) -> ()) -> Self {
#if !os(macOS)
		if #available(iOS 14, tvOS 14, *) {
			addAction(UIAction { [unowned self] _ in
				callback(self)
			}, for: .editingChanged)
			return self
		}
#endif
		let handler = auxActionHandler
		handler.onChangeCallback = { callback($0 as! Self) }
		return onChange(handler, #selector(MFActionHandler.onChange))
	}

}
public extension NSObjectProtocol where Self: MFTextField {
	@inlinable
	@discardableResult
	func onEditing(_ callback: @escaping (Self) -> ()) -> Self {
#if os(macOS)
//		let handler = auxActionHandler
//		NotificationCenter.default.addObserver(handler, selector: #selector(MFActionHandler.controlTextDidChange), name: NSControl.textDidChangeNotification, object: self)
//		self.delegate = handler
//		self.isContinuous = true
		self.onEditingCallback = { callback($0 as! Self) }
//		return onChange(handler, #selector(MFActionHandler.onChange))
		return self
#else
		return onChange(callback)

//		if #available(iOS 14, tvOS 14, *) {
//			addAction(UIAction { [unowned self] _ in callback(self) }, for: .valueChanged)
//			return self
//		}
//		let handler = auxActionHandler
//		handler.onChangeCallback = { callback($0 as! Self) }
//		return onChange(handler, #selector(MFActionHandler.onChange))
#endif
	}
}

#if !os(tvOS)
@available(macOS 10.15, *)
public extension NSObjectProtocol where Self: UXSwitch {

	@inlinable
	@discardableResult
	func onChange(_ callback: @escaping (Self) -> ()) -> Self {
		#if !os(macOS)
		if #available(iOS 14, tvOS 14, *) {
			addAction(UIAction { [unowned self] _ in callback(self) }, for: .valueChanged)
			return self
		}
		#endif
		let handler = auxActionHandler
		handler.onChangeCallback = { callback($0 as! Self) }
		return onChange(handler, #selector(MFActionHandler.onChange))
	}

}
#endif

public extension NSObjectProtocol where Self: UXPopUp {

	@inlinable
	@discardableResult
	func onChange(_ callback: @escaping (Self) -> ()) -> Self {
		#if os(macOS)
		let handler = auxActionHandler
		handler.onChangeCallback = { callback($0 as! Self) }
		return onChange(handler, #selector(MFActionHandler.onChange))
		#else
		if #available(iOS 14, tvOS 14, *) {
			addAction(UIAction { [unowned self] _ in callback(self) }, for: .valueChanged)
			return self
		}
		let handler = auxActionHandler
		handler.onChangeCallback = { callback($0 as! Self) }
		addTarget(handler, action: #selector(MFActionHandler.onChange), for: .valueChanged)
		return self
		#endif
	}
}

public extension NSObjectProtocol where Self: UXSegmentedControl {

	#if os(macOS)
	@inlinable
	@discardableResult
	func onClick(_ callback: @escaping (Self) -> ()) -> Self {
		let handler = auxActionHandler
		handler.onClickCallback = { callback($0 as! Self) }
		return onClick(handler, #selector(MFActionHandler.onClick))
	}
	#endif
	@inlinable
	@discardableResult
	func onChange(_ callback: @escaping (Self) -> ()) -> Self {
		#if !os(macOS)
		if #available(iOS 14, tvOS 14, *) {
			addAction(UIAction { [unowned self] _ in callback(self) }, for: .valueChanged)
			return self
		}
		#endif
		let handler = auxActionHandler
		handler.onChangeCallback = { callback($0 as! Self) }
		return onChange(handler, #selector(MFActionHandler.onChange))
	}
}

#if os(macOS)
public extension NSObjectProtocol where Self: UXTableView {

	@inlinable
	@discardableResult
	func onClick(_ callback: @escaping (Self) -> ()) -> Self {
		let handler = auxActionHandler
		handler.onClickCallback = { callback($0 as! Self) }
		return onClick(handler, #selector(MFActionHandler.onClick))
	}

	@inlinable
	@discardableResult
	func onDoubleClick(_ callback: @escaping (Self) -> ()) -> Self {
		let handler = auxActionHandler
		handler.onDoubleClickCallback = { callback($0 as! Self) }
		return onDoubleClick(handler, #selector(MFActionHandler.onDoubleClick))
	}

}
#endif


// For UXKit
#if os(macOS)
@available(macOS 10.15, *)
public extension NSSwitch {

	@discardableResult
	func onChange(_ target: AnyObject?, _ action: Selector) -> Self {
		self.target = target
		self.action = action
		return self
	}
}
public extension NSSlider {

	@discardableResult
	func onChange(_ target: AnyObject?, _ action: Selector) -> Self {
		self.target = target
		self.action = action
		return self
	}

}
#endif
#if os(iOS) || os(tvOS)
public extension UISegmentedControl {

	@discardableResult
	func onChange(_ target: AnyObject?, _ action: Selector) -> Self {
		addTarget(target, action: action, for: .valueChanged)
		return self
	}
}
#endif
