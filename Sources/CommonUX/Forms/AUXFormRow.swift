import Foundation
import CoreGraphics

open class AUXFormRow: UXView, AUXFormAlignable {

	public static let labelSpacing: CGFloat = 12

	public init(label: String = "", usesColon: Bool = true, @UXSingleViewBuilder _ content: () -> UXView) {
		self.label = label
		self.labelView = UXLabel(label: label)
		self.contentView = content()

		var spacing: CGFloat = 0
		#if os(iOS)
		self.labelView.adjustsFontForContentSizeCategory = true
		spacing = 6
		#endif

		super.init(frame: .zero)
		let stack = UXStackView(axis: .horizontal, alignment: .firstBaseline, spacing: AUXFormRow.labelSpacing) { [labelView, contentView] in
			labelView
			contentView
		}
		stack.translatesAutoresizingMaskIntoConstraints = false
		addSubview(stack)
		topAnchor.constraint(equalTo: stack.topAnchor, constant: -spacing).isActive = true
		bottomAnchor.constraint(equalTo: stack.bottomAnchor, constant: spacing).isActive = true
		leadingAnchor.constraint(lessThanOrEqualTo: stack.leadingAnchor).isActive = true
		leadingAnchor.constraint(equalTo: stack.leadingAnchor)
			.withPriority(.defaultLow)
			.isActive = true
		trailingAnchor.constraint(greaterThanOrEqualTo: stack.trailingAnchor).isActive = true
		trailingAnchor.constraint(equalTo: stack.trailingAnchor)
			.withPriority(.defaultLow)
			.isActive = true

		labelView.textAlignment = .right
	}
	public required init?(coder: NSCoder) {
		fatalError()
	}

	public let label: String
	public let labelView: UXLabel
	public let contentView: UXView

	static func adjustLabelText(_ text: String, usesColon: Bool) -> String {
		guard usesColon && !text.isEmpty else { return text }
		return String(format: NSLocalizedString("%@:", comment: "Label name with colon in editor."), text)
	}

	public var formGuideConstraints: [UXLayoutConstraint] = []

	public func alignContent(to guides: AUXFormLayoutGuides) {
		for c in formGuideConstraints {
			c.isActive = false
		}
		formGuideConstraints = []
		defer {
			for c in formGuideConstraints {
				c.isActive = true
			}
		}

		switch guides {
		case .basic(labelGuide: let labelGuide, contentGuide: let contentGuide):
			labelView.text = AUXFormRow.adjustLabelText(label, usesColon: true)
			labelView.textAlignment = .right
			formGuideConstraints = [
				labelView.trailingAnchor.constraint(equalTo: labelGuide.trailingAnchor),
				contentView.leadingAnchor.constraint(equalTo: contentGuide.leadingAnchor),
				self.trailingAnchor.constraint(equalTo: contentGuide.trailingAnchor),
			]
		case .outward(labelGuide: let labelGuide, contentGuide: let contentGuide):
			labelView.text = label
			labelView.textAlignment = .natural
			formGuideConstraints = [
				labelView.leadingAnchor.constraint(equalTo: labelGuide.leadingAnchor),
				contentView.leadingAnchor.constraint(greaterThanOrEqualTo: labelGuide.leadingAnchor),
				contentView.trailingAnchor.constraint(equalTo: contentGuide.trailingAnchor),
			]
		}
	}

}
