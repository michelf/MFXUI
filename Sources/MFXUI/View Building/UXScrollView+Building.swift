#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension UXScrollView {

#if os(macOS)
	public static func textContent(_ text: String, editable: Bool = false, selectable: Bool = true, contentInset: UXSize? = nil, color: UXColor? = nil, background: UXColor? = nil, font: UXFont? = nil) -> UXScrollView {
		let isHorizontalScrollingEnabled = { false }()

		let textStorage = NSTextStorage()
		let layoutManager = NSLayoutManager()
		let textContainer = NSTextContainer()
		textContainer.replaceLayoutManager(layoutManager)
		layoutManager.replaceTextStorage(textStorage)
		let textView: NSTextView = NSTextView(frame: CGRect(), textContainer: textContainer)
		let scrollView = NSScrollView()

		// setup UI
		let contentSize = scrollView.contentSize

		if isHorizontalScrollingEnabled {
			textContainer.containerSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
			textContainer.widthTracksTextView = false
		} else {
			textContainer.containerSize = CGSize(width: contentSize.width, height: CGFloat.greatestFiniteMagnitude)
			textContainer.widthTracksTextView = true
		}

		textView.minSize = CGSize(width: 0, height: 0)
		textView.maxSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
		textView.isVerticallyResizable = true
		textView.isHorizontallyResizable = isHorizontalScrollingEnabled
		textView.frame = CGRect(x: scrollView.frame.origin.x, y: scrollView.frame.origin.y, width: contentSize.width, height: contentSize.height)
		if isHorizontalScrollingEnabled {
			textView.autoresizingMask = [.width, .height]
		} else {
			textView.autoresizingMask = [.width]
		}
		textView.font = font ?? .systemFont(ofSize: 12, weight: .regular)
		textView.textContainerInset = contentInset ?? CGSize(width: 20, height: 20)
		textView.textStorage!.foregroundColor = color ?? .label
		textView.string = text
		textView.isEditable = editable
		textView.isSelectable = selectable

		scrollView.borderType = .noBorder
		scrollView.hasVerticalScroller = true
		scrollView.hasHorizontalScroller = isHorizontalScrollingEnabled
		scrollView.documentView = textView
		scrollView.backgroundColor = background ?? .textBackgroundColor

		return scrollView.withoutAutoresizingMaskConstraints()
	}
#else
	public static func textContent(_ text: String, contentInset: UXSize? = nil, color: UXColor? = nil, font: UXFont? = nil) -> UXScrollView {
		let textView = UITextView()
		textView.text = text
		if let contentInset {
			textView.contentInset = UXEdgeInsets(top: contentInset.height, left: contentInset.width, bottom: contentInset.height, right: contentInset.width)
		}
		if let color {
			textView.textColor = color
		}
		if let font {
			textView.font = font
		}

		return textView.withoutAutoresizingMaskConstraints()
	}
#endif

	public convenience init(background: UXColor? = nil, @UXSingleViewBuilder _ content: () -> UXView) {
		let isHorizontalScrollingEnabled = { false }()
#if os(macOS)
		self.init(frame: .zero)

		let content = content()
		content.translatesAutoresizingMaskIntoConstraints = false
		let containerView = UXView().withBackground(color: .systemOrange)
		containerView.addSubview(content)

		if isHorizontalScrollingEnabled {
			containerView.autoresizingMask = [.width, .height]
		} else {
			containerView.autoresizingMask = [.width]
		}

		class FlippedClipView: NSClipView {
			override var isFlipped: Bool { true }
		}
		self.contentView = FlippedClipView()

		let layoutGuide: UXLayoutGuideOrView = if #available(macOS 11, *) {
			self.contentView.safeAreaLayoutGuide
		} else {
			self.contentView
		}

		borderType = .noBorder
		hasVerticalScroller = true
		hasHorizontalScroller = isHorizontalScrollingEnabled
		self.contentView.addSubview(containerView)
		documentView = content
		if let background {
			backgroundColor = background
		}
		assert(containerView.superview == self.contentView)

		layoutGuide.widthAnchor.constraint(equalTo: content.widthAnchor).isActive = true
#else
		self.init()

		let content = content()
		content.translatesAutoresizingMaskIntoConstraints = false

		let containerView = self
		self.isScrollEnabled = true
		self.alwaysBounceVertical = true

		let layoutGuide = safeAreaLayoutGuide
		self.backgroundColor = background
		containerView.addSubview(content)

		let widthConstraint = layoutGuide.widthAnchor.constraint(equalTo: content.widthAnchor)
		let heightConstraint = layoutGuide.heightAnchor.constraint(lessThanOrEqualTo: content.heightAnchor)
		heightConstraint.priority = .init(1)

		addConstraints([
			contentLayoutGuide.topAnchor.constraint(equalTo: content.topAnchor),
			contentLayoutGuide.bottomAnchor.constraint(lessThanOrEqualTo: content.bottomAnchor),
			contentLayoutGuide.leadingAnchor.constraint(equalTo: content.leadingAnchor),
			contentLayoutGuide.trailingAnchor.constraint(equalTo: content.trailingAnchor),
		])
		containerView.addConstraints([widthConstraint, heightConstraint])
#endif
	}

}

private protocol UXLayoutGuideOrView: NSObjectProtocol {
	var widthAnchor: NSLayoutDimension { get }
	var heightAnchor: NSLayoutDimension { get }
}
extension UXView: UXLayoutGuideOrView {}
extension UXLayoutGuide: UXLayoutGuideOrView {}
