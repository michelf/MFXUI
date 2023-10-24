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

}
