#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension UXTextField {

	public convenience init(text: String = "", placeholder: String = "", font: UXFont? = nil, alignment: UXTextAlignment? = nil, color: UXColor? = nil, maxLines: Int? = nil) {
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
		self.maximumNumberOfLines = maxLines ?? 1
		lineBreakMode = .byTruncatingTail
		self.text = text
		self.translatesAutoresizingMaskIntoConstraints = false
	}

}
