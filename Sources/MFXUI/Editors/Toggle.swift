import CoreGraphics

/// A boolean value that
public protocol MFToggleValue: Equatable {
	init(_ bool: Bool)
	var uniformValue: Bool? { get }
}
extension MFToggleValue {
	public var uniformValue: Bool? {
		if self == Self(true) {
			return true
		} else if self == Self(false) {
			return false
		} else {
			return nil
		}
	}
}
extension Bool: MFToggleValue {}
extension Bool?: MFToggleValue {}

#if os(macOS)
public class MFToggle<ToggleValue: MFToggleValue>: UXButton {
}
#else
public class MFToggle<ToggleValue: MFToggleValue>: UXButton {

	var isOn: Bool = false {
		didSet {
			updateForOnState()
		}
	}

	public override func didMoveToSuperview() {
		updateForOnState()
		super.didMoveToSuperview()
	}

	private func updateForOnState() {
		setNeedsLayout()
	}

	public override func layoutSubviews() {
		super.layoutSubviews()

#if os(tvOS)
		layer.cornerRadius = 10
		backgroundColor = isOn ? #colorLiteral(red: 0.2686295869, green: 0.7407836062, blue: 0.9660173767, alpha: 1) : nil
		tintColor = isOn ? .black : nil
		for view in [imageView, titleLabel].compactMap({ $0 }) {
			view.superview?.backgroundColor = backgroundColor
		}
#else
		layer.cornerCurve = .continuous
#if targetEnvironment(macCatalyst)
		layer.cornerRadius = 8
#else
		layer.cornerRadius = frame.height / 4
#endif
		adjustColors()
#endif
	}

#if os(iOS)
	public override func tintColorDidChange() {
		super.tintColorDidChange()
		adjustColors()
	}

	func adjustColors() {
#if targetEnvironment(macCatalyst)
		backgroundColor = isOn ? Theme.current.selectedBackground : nil//.quaternaryLabel
		tintColor = isOn ? .white : Theme.current.selectedBackground
#else
		backgroundColor = isOn ? superview?.tintColor : .systemFill
		tintColor = isOn ? .black : nil
#endif
	}
#endif

#if os(iOS)
	public override var intrinsicContentSize: CGSize {
#if targetEnvironment(macCatalyst)
		let minWidth: CGFloat = 44
		let marginWidth: CGFloat = 0
#else
		let minWidth: CGFloat = 44
		let marginWidth: CGFloat = 12
#endif
		var size = super.intrinsicContentSize
		size.width = max(minWidth, size.width)
		size.width = max(size.height + marginWidth, size.width)
		size.height = max(size.height, size.width - marginWidth)
		return size
	}
#endif

}
#endif

extension MFToggle: MFEditable {

	#if os(macOS)
	public class func checkBox(_ accessor: MFEditableAccessor<ToggleValue>, title: String) -> Self {
		self.init(checkboxWithTitle: title, target: nil, action: nil)
			.editing(accessor)
	}

	public class func radio<Value>(_ accessor: MFEditableAccessor<Value>, representedValue: Value, title: String) -> Self where ToggleValue == Bool {
		self.init(radioButtonWithTitle: title, target: nil, action: nil)
			.onClick { _ in
				accessor.set(representedValue)
			}
			.binding {
				$0.isOn = accessor.get() == representedValue
			}
	}
	#endif

	public class func button(_ accessor: MFEditableAccessor<ToggleValue>, title: String) -> Self {
		#if os(macOS)
		self.init(title: title, target: nil, action: nil)
			.editing(accessor)
		#else
		self.init(type: .system)
			.editing(accessor)
		#endif
	}

	public class func `switch`(_ accessor: MFEditableAccessor<Bool>, title: String) -> UXControl where ToggleValue == Bool {
		#if os(macOS) || os(iOS)
		if #available(macOS 10.15, *) {
			return UXSwitch().editing(accessor)
		}
		#endif
		return Self.button(accessor, title: title)
	}

	public var editableValue: ToggleValue {
		get {
			ToggleValue(isOn)
		}
		set {
			#if os(macOS)
			switch newValue.uniformValue {
			case .some(true):  state = .on
			case .some(false): state = .off
			case nil:          state = .mixed
			}
			#else
			// No support for mixed state on iOS/tvOS
			// mixed state is shown as `true`
			isOn = newValue.uniformValue ?? true
			#endif
		}
	}
	public func onEditing(_ callback: @escaping (ToggleValue) -> ()) -> Self {
		onClick { callback($0.editableValue) }
	}

}

#if os(macOS)
import AppKit
#else
import UIKit
#endif

#if os(macOS) || os(iOS)
@available(macOS 10.15, *)
extension UXSwitch: MFEditable {

	public class func `switch`(_ accessor: MFEditableAccessor<Bool>, title: String) -> UXControl {
		Self().editing(accessor)
	}

	#if os(macOS)
	public var isOn: Bool {
		set { state = newValue ? .on : .off }
		get { return state == .on }
	}
	#endif

	public var editableValue: Bool {
		get { isOn }
		set { isOn = newValue }
	}

	public func onEditing(_ callback: @escaping (Bool) -> ()) -> Self {
		onChange { callback($0.editableValue) }
	}


}
#endif
