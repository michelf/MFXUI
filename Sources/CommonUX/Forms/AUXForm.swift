import Foundation

public enum AUXFormLayoutGuides {
	case basic(labelGuide: UXLayoutGuide, contentGuide: UXLayoutGuide)
	case outward(labelGuide: UXLayoutGuide, contentGuide: UXLayoutGuide)
}

public protocol AUXFormAlignable {
	func alignContent(to guides: AUXFormLayoutGuides)
}
extension UXView {
	func alignSubviews(to guides: AUXFormLayoutGuides) {
		for subview in self.subviews {
			(subview as? AUXFormAlignable)?.alignContent(to: guides)
			subview.alignSubviews(to: guides)
		}
	}
}

open class AUXFormView: UXView {

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

	public init(layout: Layout = .default, @UXViewBuilder _ subviews: () -> [UXView]) {
		self.stack = UXStackView(axis: .vertical, spacing: AUXFormView.rowSpacing, subviews)

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
			bottomAnchor.constraint(equalTo: stack.bottomAnchor),
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
			contentGuide.leadingAnchor.constraint(equalTo: labelGuide.trailingAnchor, constant: AUXFormRow.labelSpacing),
			contentGuide.trailingAnchor.constraint(equalTo: trailingAnchor),
		])

		labelGuide.widthAnchor.constraint(equalTo: contentGuide.widthAnchor, multiplier: 0.5)
			.withPriority(.defaultHigh)
			.isActive = true
		labelGuide.widthAnchor.constraint(lessThanOrEqualTo: contentGuide.widthAnchor, multiplier: 1)
			.withPriority(.required)
			.isActive = true

		alignSubviews(to: guides)
	}
	
	public required init?(coder: NSCoder) {
		fatalError()
	}

	public let stack: UXStackView
	public let guides: AUXFormLayoutGuides

}
