import Foundation

public enum MFFormLayoutGuides {
	case basic(labelGuide: UXLayoutGuide, contentGuide: UXLayoutGuide)
	case outward(labelGuide: UXLayoutGuide, contentGuide: UXLayoutGuide)
}

public protocol MFFormAlignable {
	func alignContent(to guides: MFFormLayoutGuides)
}
extension UXView {
	func alignSubviews(to guides: MFFormLayoutGuides) {
		for subview in self.subviews {
			(subview as? MFFormAlignable)?.alignContent(to: guides)
			subview.alignSubviews(to: guides)
		}
	}
}

open class MFFormView: UXView {

	public static let rowSpacing: CGFloat = 10

	public enum Layout {
		case basic
		case outward

		public static var `default`: Layout {
#if os(macOS)
			return .basic
#else
			return .outward
#endif
		}
	}

	public init(layout: Layout = .default, labelWidthRatio: CGFloat? = nil, @UXViewBuilder _ subviews: () -> [UXView]) {
		self.stack = UXStackView(axis: .vertical, spacing: MFFormView.rowSpacing, subviews)

		let labelGuide = UXLayoutGuide()
		let contentGuide = UXLayoutGuide()
		self.guides = switch layout {
		case .basic:
			.basic(labelGuide: labelGuide, contentGuide: contentGuide)
		case .outward:
			.outward(labelGuide: labelGuide, contentGuide: contentGuide)
		}

		super.init(frame: .zero)
		self.translatesAutoresizingMaskIntoConstraints = false
		stack.translatesAutoresizingMaskIntoConstraints = false
		addSubview(stack)
		addConstraints([
			topAnchor.constraint(equalTo: stack.topAnchor),
			leftAnchor.constraint(equalTo: stack.leftAnchor),
			widthAnchor.constraint(equalTo: stack.widthAnchor),
			heightAnchor.constraint(equalTo: stack.heightAnchor),
		])

		addLayoutGuide(labelGuide)
		addLayoutGuide(contentGuide)
		addConstraints([
			labelGuide.topAnchor.constraint(equalTo: topAnchor),
			labelGuide.bottomAnchor.constraint(equalTo: bottomAnchor),
			contentGuide.topAnchor.constraint(equalTo: topAnchor),
			contentGuide.bottomAnchor.constraint(equalTo: bottomAnchor),
			labelGuide.leadingAnchor.constraint(equalTo: leadingAnchor),
			contentGuide.leadingAnchor.constraint(equalTo: labelGuide.trailingAnchor, constant: MFFormRow.labelSpacing),
			contentGuide.trailingAnchor.constraint(equalTo: trailingAnchor),
		])

		if let labelWidthRatio {
			labelGuide.widthAnchor.constraint(equalTo: contentGuide.widthAnchor, multiplier: labelWidthRatio)
				.withPriority(.defaultHigh)
				.isActive = true
		}
		labelGuide.widthAnchor.constraint(lessThanOrEqualTo: contentGuide.widthAnchor, multiplier: 1)
			.withPriority(.required)
			.isActive = true

		alignSubviews(to: guides)
	}
	
	public required init?(coder: NSCoder) {
		fatalError()
	}

	public let stack: UXStackView
	public let guides: MFFormLayoutGuides

}
