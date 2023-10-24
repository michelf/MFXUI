#if os(macOS)
import AppKit
public typealias UXStackViewAxis    = NSUserInterfaceLayoutOrientation
#else
import UIKit
public typealias UXStackViewAxis    = NSLayoutConstraint.Axis
#endif

extension UXStackView { 

	public convenience init(axis: UXStackViewAxis = .vertical, alignment: NSLayoutConstraint.Attribute? = nil, spacing: UXFloat = 0, @UXViewBuilder _ subviews: () -> [UXView]) {
		let subviews = subviews()
//		for (index, subview) in subviews.enumerated() {
//			subview.translatesAutoresizingMaskIntoConstraints = false
//		}
#if os(macOS)
		self.init(views: subviews)
		self.orientation = axis
#else
		self.init(arrangedSubviews: subviews)
		self.axis = axis
#endif
		if let alignment {
			self.alignment = alignment
		}
		self.spacing = spacing
		self.translatesAutoresizingMaskIntoConstraints = false
	}

}
