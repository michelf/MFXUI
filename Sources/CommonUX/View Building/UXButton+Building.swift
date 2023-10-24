import Foundation

#if os(macOS)
import AppKit
#else
import UIKit
#endif

public enum UXControlSize {
	case regular
	case small
	case mini
	case large

	#if os(macOS)
	var controlSize: NSControl.ControlSize {
		switch self {
		case .regular: return .regular
		case .small: return .small
		case .mini: return .mini
		case .large:
			if #available(macOS 11, *) {
				return .large
			}
			return .regular
		}
	}
	#endif
}

extension UXButton {

	public struct UXStyle {
		let transform: (UXButton) -> ()
		public init(_ transform: @escaping (UXButton) -> ()) {
			self.transform = transform
		}
	}

	public convenience init(title: String, image: UXImage? = nil, key: String? = nil, style: UXStyle = .regular, font: UXFont? = nil, target: AnyObject? = nil, action: Selector? = nil) {
		self.init()
		self.translatesAutoresizingMaskIntoConstraints = false
		#if os(macOS)
		self.bezelStyle = .rounded
		#endif
		if let key {
			#if os(macOS)
			self.keyEquivalent = key
			#else
			#endif
		}
		self.title = title
		self.image = image
		if let action {
#if os(macOS)
			self.target = target
			self.action = action
#else
			self.addTarget(target, action: action, for: .touchUpInside)
#endif
		}
		style.transform(self)
		if let font = font {
			self.font = font
		}
	}

}

extension UXButton.UXStyle {

	/// A regular push button
	public static let regular = Self {
#if os(macOS)
		$0.controlSize = .regular
		_ = $0.constrainingMinSize(width: 80, height: nil)
#else
#endif
	}
	/// A large push button, suitable for main actions in alert-like panels.
	///
	/// Same as regular on older macOS.
	public static let large = Self {
#if os(macOS)
		if #available(macOS 11.0, *) {
			$0.controlSize = .large
		} else {
			$0.controlSize = .regular
		}
		_ = $0.constrainingMinSize(width: 80, height: nil)
#else
#endif
	}
	/// A small push button, suitable for auxilary actions.
	public static let small = Self {
#if os(macOS)
		$0.controlSize = .small
		_ = $0.constrainingMinSize(width: 80, height: nil)
#else
#endif
	}
	/// A transparent small push button, suiutable for auxiliary actions.
	public static let transparentSmall = Self {
#if os(macOS)
		$0.bezelStyle = .roundRect
		$0.controlSize = .small
		_ = $0.constrainingMinSize(width: 80, height: nil)
#else
#endif
	}
	/// A transparent small push button, suiutable for auxiliary actions.
	public static let transparent = Self {
#if os(macOS)
		$0.bezelStyle = .roundRect
		$0.controlSize = .regular
		$0.font = .small()
		_ = $0.constrainingMinSize(width: 80, height: nil)
#else
#endif
	}
	/// A button linking to a web page
	public static let smallLink = Self {
#if os(macOS)
		let title = $0.title
		$0.bezelStyle = .recessed
		$0.controlSize = .small
		$0.showsBorderOnlyWhileMouseInside = true
		$0.isBordered = false
		$0.imagePosition = .imageLeading
		$0.font = .systemFont(ofSize: UXFont.systemFontSize(for: .small), weight: .semibold)
		if $0.image == nil {
			$0.image = UXImage(named: "NSFollowLinkFreestandingTemplate")
		}
		_ = $0.constrainingMinSize(width: 80, height: nil)
		$0.title = title
#else
#endif
	}

}
