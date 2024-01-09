import Foundation

#if os(macOS)
import AppKit
#else
import UIKit
#endif

@available(tvOS 17, *)
extension UXPopUp {

	public convenience init(title: String, image: UXImage? = nil, style: UXStyle = .regular, font: UXFont? = nil, @MFMenuBuilder<Never> elements: () -> [UXMenuElement]) {
		self.init(title: title, image: image, key: nil, style: style, font: font)
#if os(macOS)
		self.pullsDown = true
		let titleItem = NSMenuItem(title: title)
		titleItem.image = image
		let menu = NSMenu()
		menu.items = [titleItem] + elements()
		self.menu = menu
#else
		self.showsMenuAsPrimaryAction = true
		self.menu = UIMenu(children: elements())
#endif
	}

}

@available(tvOS 17.0, *)
extension UXAction {

	public convenience init(title: String, handler callback: ((UXAction) -> ())? = nil) {
		#if os(macOS)
		self.init(title: title, action: nil, keyEquivalent: "")
		if let callback {
			let handler = self.auxActionHandler
			handler.onClickCallback = { callback($0 as! UXAction) }
			self.target = handler
			self.action = #selector(handler.onClick)
		}
		#else
		self.init(title: title, image: nil, identifier: nil, discoverabilityTitle: nil, attributes: [], state: .off, handler: callback ?? { _ in })
		#endif
	}

	internal convenience init<Value: Equatable>(title: String, _value: Value) {
		#if os(macOS)
		self.init(title: title, action: nil, keyEquivalent: "")
		self.representedObject = _value
		#else
		self.init(title: title) { action in
			let picker = action.sender as! MFPopUpPicker<Value>
			picker.pickValue(_value, from: action)
		}
		self.auxRepresentedObject = _value
		#endif
	}

}

#if !os(macOS)
extension UXAction {
	@usableFromInline
	internal static var _auxRepresentedObjectKey: Int8 = 0

	@usableFromInline
	internal var auxRepresentedObject: Any? {
		get {
			objc_getAssociatedObject(self, &UXAction._auxRepresentedObjectKey)
		}
		set {
			objc_setAssociatedObject(self, &UXAction._auxRepresentedObjectKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}
}
#endif
