#if os(macOS)
import AppKit
#else
import UIKit
#endif

public typealias UXTextAlignment = NSTextAlignment

extension UXLabel {

	public convenience init(label text: String, alignment: UXTextAlignment? = nil, color: UXColor? = nil, font: UXFont? = nil, selectable: Bool = false) {
		self.init()
		#if os(macOS)
		isBordered = false
		isEditable = false
		isSelectable = selectable
		drawsBackground = false
		backgroundColor = nil
		#endif
		translatesAutoresizingMaskIntoConstraints = false
		if let color {
			self.textColor = color
		}
		self.font = font ?? .body
		if let alignment {
			self.textAlignment = alignment
		}
		self.text = text
		self.translatesAutoresizingMaskIntoConstraints = false
	}

//	public convenience init(alignment: UXTextAlignment? = nil, color: UXColor? = nil, font: UXFont? = nil, @StringBuilder text: () -> String) {
//		self.init(label: text(), alignment: alignment, color: color, font: font)
//	}

}
