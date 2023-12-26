import UXKit
#if os(macOS)
import AppKit
#else
import UIKit
#endif

#if os(macOS)
@usableFromInline
internal final class AUXActionHandler: NSObject, NSTextFieldDelegate {

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
	@objc func controlTextDidChange(_ obj: Notification) {
		onChangeCallback?(obj.object as AnyObject)
	}

	@usableFromInline
	internal static var _associatedValueKey: Int8 = 0

}

extension NSObjectProtocol where Self: UXView {

	@usableFromInline
	var auxActionHandler: AUXActionHandler {
		if let handler = objc_getAssociatedObject(self, &AUXActionHandler._associatedValueKey) as! AUXActionHandler? {
			return handler
		} else {
			let handler = AUXActionHandler()
			objc_setAssociatedObject(self, &AUXActionHandler._associatedValueKey, handler, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
			return handler
		}
	}

}
#endif

public extension NSObjectProtocol where Self: UXButton {

	@inlinable
	@discardableResult
	func onClick(_ callback: @escaping (Self) -> ()) -> Self {
		#if os(macOS)
		let handler = auxActionHandler
		handler.onChangeCallback = { callback($0 as! Self) }
		return onClick(handler, #selector(AUXActionHandler.onClick))
		#else
		addAction(UIAction { [unowned self] _ in callback(self) }, for: .touchUpInside)
		return self
		#endif
	}

}

public extension NSObjectProtocol where Self: UXTextField {

	@inlinable
	@discardableResult
	func onChange(_ callback: @escaping (Self) -> ()) -> Self {
		#if os(macOS)
		let handler = auxActionHandler
		handler.onChangeCallback = { callback($0 as! Self) }
		return onChange(handler, #selector(AUXActionHandler.onChange))
		#else
		addAction(UIAction { [unowned self] _ in callback(self) }, for: .valueChanged)
		return self
		#endif
	}
	@inlinable
	@discardableResult
	func onEditing(_ callback: @escaping (Self) -> ()) -> Self {
#if os(macOS)
		let handler = auxActionHandler
		//		handler.onChangeCallback = { callback($0 as! Self) }
		//		return onChange(handler, #selector(AUXActionHandler.onChange))
		NotificationCenter.default.addObserver(handler, selector: #selector(AUXActionHandler.controlTextDidChange), name: NSControl.textDidChangeNotification, object: self)
		self.delegate = handler
		return self
#else
		addAction(UIAction { [unowned self] _ in callback(self) }, for: .valueChanged)
		return self
#endif
	}
}

#if !os(tvOS)
@available(macOS 10.15, *)
public extension NSObjectProtocol where Self: UXSwitch {

	@inlinable
	@discardableResult
	func onChange(_ callback: @escaping (Self) -> ()) -> Self {
		#if os(macOS)
		let handler = auxActionHandler
		handler.onChangeCallback = { callback($0 as! Self) }
		return onChange(handler, #selector(AUXActionHandler.onChange))
		#else
		addAction(UIAction { [unowned self] _ in callback(self) }, for: .valueChanged)
		return self
		#endif
	}

}
#endif

#if os(macOS)
public extension NSObjectProtocol where Self: UXPopUp {

	@inlinable
	@discardableResult
	func onChange(_ callback: @escaping (Self) -> ()) -> Self {
#if os(macOS)
		let handler = auxActionHandler
		handler.onChangeCallback = { callback($0 as! Self) }
		return onChange(handler, #selector(AUXActionHandler.onChange))
#else
		addAction(UIAction { [unowned self] _ in callback(self) }, for: .valueChanged)
		return self
#endif
	}
}
#endif

public extension NSObjectProtocol where Self: UXSegmentedControl {

	#if os(macOS)
	@inlinable
	@discardableResult
	func onClick(_ callback: @escaping (Self) -> ()) -> Self {
		#if os(macOS)
		let handler = auxActionHandler
		handler.onClickCallback = { callback($0 as! Self) }
		return onClick(handler, #selector(AUXActionHandler.onClick))
		#else
		addAction(UIAction { [unowned self] _ in callback(self) }, for: .touchUpInside)
		return self
		#endif
	}
	#endif
	@inlinable
	@discardableResult
	func onChange(_ callback: @escaping (Self) -> ()) -> Self {
		#if os(macOS)
		let handler = auxActionHandler
		handler.onChangeCallback = { callback($0 as! Self) }
		return onChange(handler, #selector(AUXActionHandler.onChange))
		#else
		addAction(UIAction { [unowned self] _ in callback(self) }, for: .valueChanged)
		return self
		#endif
	}
}

#if os(macOS)
public extension NSObjectProtocol where Self: UXTableView {

	@inlinable
	@discardableResult
	func onClick(_ callback: @escaping (Self) -> ()) -> Self {
		let handler = auxActionHandler
		handler.onClickCallback = { callback($0 as! Self) }
		return onClick(handler, #selector(AUXActionHandler.onClick))
	}

	@inlinable
	@discardableResult
	func onDoubleClick(_ callback: @escaping (Self) -> ()) -> Self {
		let handler = auxActionHandler
		handler.onDoubleClickCallback = { callback($0 as! Self) }
		return onDoubleClick(handler, #selector(AUXActionHandler.onDoubleClick))
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
