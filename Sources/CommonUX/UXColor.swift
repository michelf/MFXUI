#if os(macOS)
import AppKit
#endif

extension UXColor {

	#if os(macOS)
	public static var label: UXColor { labelColor }
	public static var secondaryLabel: UXColor { secondaryLabelColor }
	public static var tertiaryLabel: UXColor { tertiaryLabelColor }
	public static var quaternaryLabel: UXColor { quaternaryLabelColor }

	@available(macOS 10.14, *)
	public static var accentColor: UXColor {
		controlAccentColor
	}
	#endif

	/// Optional accent colors returns nil under macOS 10.13 and earlier, and also on iOS where
	/// `tintColor` set to nil will propagate the accent color.
	public static var optionalAccentColor: UXColor? {
		#if os(macOS)
		if #available(macOS 10.14, *) {
			return accentColor
		}
		#endif
		return nil
	}

}
