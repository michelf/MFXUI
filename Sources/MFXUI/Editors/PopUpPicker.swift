#if os(macOS)
import AppKit
#else
import UIKit
#endif

@available(tvOS 17, *)
public class MFPopUpPicker<Value: Equatable>: UXPopUp {

	public class func popUpMenu(_ accessor: MFEditableAccessor<Value>, style: UXStyle = .regular, font: UXFont? = nil, @MFMenuBuilder<Value> options: () -> [UXMenuElement]) -> MFPopUpPicker {
		MFPopUpPicker(style: style, font: font, options: options)
			.editing(accessor)
	}

	private convenience init(style: UXStyle = .regular, font: UXFont? = nil, @MFMenuBuilder<Value> options: () -> [UXMenuElement]) {
		#if os(macOS)
		Self.cellClass = MFPopUpPickerCell<Value>.self
		#endif
		// standard button init
		self.init(title: "?", image: nil, key: nil, style: style, font: font)
#if os(macOS)
		self.pullsDown = false
		let menu = NSMenu()
		menu.items = options()
		self.menu = menu
#else
		self.showsMenuAsPrimaryAction = true
		let menu = UIMenu(children: options())
		self.menuTemplate = menu
		self.menu = menu
#endif
		// select first
		enumerateAllOptions { option, value, stop in
			select(option)
			stop = true
		}
	}

	#if !os(macOS)
	// can't change state and associated objects are broken once the menu
	// is set, so keep the original as a template
	var menuTemplate: UIMenu!
	func pickValue(_ selectedValue: Value, from action: UXAction) {
		select(action)
		sendActions(for: .valueChanged)
	}
	#endif

	#if os(macOS)
	private var _value: Value {
		get { (cell as! MFPopUpPickerCell)._value }
		set { (cell as! MFPopUpPickerCell)._value = newValue }
	}
	private var _selectedOption: UXAction? {
		get { (cell as! MFPopUpPickerCell)._value }
	}
	#else
	private var _value: Value!
	private var _selectedOption: UXAction?
	func select(_ action: UXAction?) {
		var found: (option: UXAction, value: Value)?
		if let action {
			// find original action in our template menu
			enumerateAllOptions { option, value, stop in
				if option.identifier == action.identifier {
					found = (option, value as! Value)
				}
			}
		}
		_selectedOption?.state = .off
		_selectedOption = found?.option
		_selectedOption?.state = .on
		_value = found?.value
		setTitle(_selectedOption?.title, for: .normal)
		setImage(_selectedOption?.image, for: .normal)
		menu = menuTemplate
	}
	#endif

	public var value: Value {
		get { _value }
		set {
			guard newValue != _value else { return }
			_value = newValue
			var found = false
			enumerateAllOptions { option, value, stop in
				let value = value as! Value
				if value == newValue {
					select(option)
					found = true
					stop = true
				}
			}
			if !found {
				select(nil)
			}
		}
	}

	func enumerateAllOptions(_ apply: (UXAction, Any, inout Bool) -> ()) {
		#if os(macOS)
		menu?.enumerateAllOptions(apply)
		#else
		menuTemplate?.enumerateAllOptions(apply)
		#endif
	}

}

#if os(macOS)
private class MFPopUpPickerCell<Value>: NSPopUpButtonCell {
	fileprivate var _value: Value!
	fileprivate var _selectedOption: UXAction?

	public override func select(_ item: NSMenuItem?) {
		if let item {
			guard let value = item.representedObject as? Value else {
				return // don't allow selecting this item
			}
			_value = value
			_selectedOption = item
		} else {
			_value = nil
			_selectedOption = nil
		}
		super.select(item)
	}
	override var indexOfSelectedItem: Int {
		let index = super.indexOfSelectedItem
		guard index != -1 else { return index }
		let itemAtIndex = itemArray[index]
		if itemAtIndex.representedObject as? Value != nil {
			return index // valid item at index
		}
		// not a valid item, fall back to previously selected item
		if let _selectedOption {
			return menu?.index(of: _selectedOption) ?? -1
		} else {
			return -1
		}
	}
}
#endif

#if os(macOS)
extension NSMenu {
	@discardableResult
	func enumerateAllOptions(_ apply: (NSMenuItem, Any, inout Bool) -> ()) -> Bool {
		var stop = false
		for item in items {
			if let value = item.representedObject {
				apply(item, value, &stop)
			}
			if let submenu = item.submenu {
				stop = submenu.enumerateAllOptions(apply)
			}
			if stop { return true }
		}
		return false
	}
}
#else
extension UIMenu {
	@discardableResult
	func enumerateAllOptions(_ apply: (UIAction, Any, inout Bool) -> ()) -> Bool {
		var stop = false
		for element in children {
			switch element {
			case let action as UIAction:
				if let value = action.auxRepresentedObject {
					apply(action, value, &stop)
				}
			case let menu as UIMenu:
				stop = menu.enumerateAllOptions(apply)
			default:
				break
			}
			if stop { return true }
		}
		return false
	}
}
#endif


@available(tvOS 17, *)
extension MFPopUpPicker: MFEditable {
	public var editableValue: Value {
		get { value }
		set { value = newValue }
	}
	public func onEditing(_ callback: @escaping (Value) -> ()) -> Self {
		onChange { callback($0.editableValue) }
	}
}

#if os(macOS)
#else
extension UXAction {
	public var isHidden: Bool {
		get { attributes.contains(.hidden) }
		set {
			if newValue {
				attributes.insert(.hidden)
			} else {
				attributes.remove(.hidden)
			}
		}
	}
	public var isEnabled: Bool {
		get { !attributes.contains(.disabled) }
		set {
			if !newValue {
				attributes.insert(.disabled)
			} else {
				attributes.remove(.disabled)
			}
		}
	}
	public var isDestructive: Bool {
		get { attributes.contains(.destructive) }
		set {
			if newValue {
				attributes.insert(.destructive)
			} else {
				attributes.remove(.destructive)
			}
		}
	}
}
#endif
