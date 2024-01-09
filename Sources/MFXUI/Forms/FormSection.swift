import Foundation

open class MFFormSection: UXView, MFFormAlignable {

	public static let labelSpacing: CGFloat = 12

	public init(title: String = "", footer: String = "", separator: Bool = true, @UXSingleViewBuilder _ content: () -> UXView) {
		self.titleView = UXLabel(label: title, font: .headline)
		self.footerView = UXLabel(label: footer, font: .subheadline)
		self.contentView = content()

		#if os(iOS)
		self.footerView.numberOfLines = 0
		self.titleView.numberOfLines = 0
		#endif

		super.init(frame: .zero)
		let stack = UXStackView(axis: .vertical, alignment: .leading, spacing: MFFormRow.labelSpacing) { [titleView, contentView, footerView] in
			if separator {
				UXView.separator(axis: .horizontal)
			}
			if !title.isEmpty {
				titleView
			}
			contentView
			if !footer.isEmpty {
				footerView
			}
		}
		stack.translatesAutoresizingMaskIntoConstraints = false
		addSubview(stack)
		topAnchor.constraint(equalTo: stack.topAnchor).isActive = true
		bottomAnchor.constraint(equalTo: stack.bottomAnchor).isActive = true
		leadingAnchor.constraint(lessThanOrEqualTo: stack.leadingAnchor).isActive = true
		leadingAnchor.constraint(equalTo: stack.leadingAnchor)
			.withPriority(.defaultLow)
			.isActive = true
		trailingAnchor.constraint(greaterThanOrEqualTo: stack.trailingAnchor).isActive = true
		trailingAnchor.constraint(equalTo: stack.trailingAnchor)
			.withPriority(.defaultLow)
			.isActive = true

		titleView.textAlignment = .right
	}
	public required init?(coder: NSCoder) {
		fatalError()
	}

	public let titleView: UXLabel
	public let contentView: UXView
	public let footerView: UXLabel

	var formGuideConstraints: [UXLayoutConstraint] = []

	public func alignContent(to guides: MFFormLayoutGuides) {
		for constraint in formGuideConstraints {
			constraint.isActive = false
		}
		formGuideConstraints = []
		defer {
			for constraint in formGuideConstraints {
				constraint.isActive = true
			}
		}

		switch guides {
		case .basic(labelGuide: let labelGuide, contentGuide: let contentGuide),
				.outward(labelGuide: let labelGuide, contentGuide: let contentGuide):
			formGuideConstraints = [
				//				titleView.trailingAnchor.constraint(equalTo: labelGuide.trailingAnchor),
				self.leadingAnchor.constraint(equalTo: labelGuide.leadingAnchor),
				self.trailingAnchor.constraint(equalTo: contentGuide.trailingAnchor),
			]
		}
	}

}
