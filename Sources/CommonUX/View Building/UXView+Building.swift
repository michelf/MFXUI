#if os(macOS)
import AppKit
#else
import UIKit
#endif
import UXKit

extension UXView {

	public static func box(border: UXColor? = nil, fill: UXColor? = nil, cornerRadius: UXFloat? = nil, @UXSingleViewBuilder _ content: () -> UXView) -> UXView {
		let content = content()
		content.translatesAutoresizingMaskIntoConstraints = false
		var borderOffset: CGFloat = 0
#if os(macOS)
		let box = NSBox(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
		if border == nil && fill == nil {
			box.boxType = .primary
		} else {
			box.boxType = .custom
			box.contentViewMargins = .zero
			if let border {
				box.borderColor = border
			} else {
				box.borderWidth = 0
			}
			if let fill {
				box.fillColor = fill
			}
		}
		if let cornerRadius {
			box.cornerRadius = cornerRadius
			box.contentView?.wantsLayer = true
			box.contentView?.layer?.cornerRadius = cornerRadius - 1.1
		}
		let contentView = box.contentView!
#else
		let box = UXView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
		if let border {
			box.layer.borderColor = border.cgColor
			box.layer.borderWidth = 1
			borderOffset += 1
		}
		if let fill {
			box.backgroundColor = fill
		}
		let contentView = box
#endif
		contentView.addSubview(content)
		contentView.addConstraints([
			contentView.topAnchor.constraint(equalTo: content.topAnchor, constant: borderOffset),
			contentView.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -borderOffset),
			contentView.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: borderOffset),
			contentView.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -borderOffset),
		])
		return box.withoutAutoresizingMaskConstraints().withFlexibility(horizontal: true, vertical: true)
	}

	public static func separator(axis: UXStackViewAxis, color: UXColor? = nil) -> UXView {
#if os(macOS)
		let separator = NSBox(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
		separator.boxType = .separator
		if let color {
			separator.boxType = .custom
			separator.borderColor = color
		}
#else
		let separator = UXView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
		separator.backgroundColor = color ?? .tertiaryLabel
#endif
		return separator.withoutAutoresizingMaskConstraints().withFlexibility(alongAxis: axis)
	}

	public static func spacer(axis: UXStackViewAxis) -> UXView {
		let spacer = UXView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
		return spacer.withoutAutoresizingMaskConstraints().withFlexibility(alongAxis: axis)
	}

}
