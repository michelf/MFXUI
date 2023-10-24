#if os(macOS)
import AppKit
#else
import UIKit
#endif
import UXKit

extension UXControl {

	public static func spinner(hidesWhenStopped: Bool = true, controlSize: UXControlSize? = nil) -> UXSpinner {
		let spinner = UXSpinner()
#if os(macOS)
		spinner.style = .spinning
		spinner.controlSize = controlSize?.controlSize ?? .small
#else
#endif
		spinner.hidesWhenStopped = hidesWhenStopped
		return spinner
			.withoutAutoresizingMaskConstraints()
			.withFlexibility(horizontal: false, vertical: false)
	}

}
