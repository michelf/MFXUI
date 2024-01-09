#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension UXTextField {

	public convenience init(
		text: String = "",
		placeholder: String = "",
		font: UXFont? = nil,
		alignment: UXTextAlignment? = nil,
		color: UXColor? = nil,
		maxLines: Int? = nil,
		lineBreakMode: NSLineBreakMode? = nil
	) {
		self.init()
		#if os(macOS)
		isEditable = true
		isSelectable = true
		drawsBackground = false
		#endif
		backgroundColor = nil
		translatesAutoresizingMaskIntoConstraints = false
		self.placeholder = placeholder
		if let color {
			self.textColor = color
		}
		if let font {
			self.font = font
		}
		if let alignment {
			self.textAlignment = alignment
		}
		#if os(macOS)
		self.maximumNumberOfLines = maxLines ?? 0
		self.lineBreakMode = maxLines == 1 ? .byTruncatingTail : .byWordWrapping
		#endif
		self.text = text
		self.translatesAutoresizingMaskIntoConstraints = false
	}

}
