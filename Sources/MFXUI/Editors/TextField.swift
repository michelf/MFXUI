#if os(macOS)
import AppKit

/// A text field where the intrinsic size adjusts itself vertically to fit its
/// content.
open class MFTextField: NSTextField {

	public override var intrinsicContentSize: NSSize {
		let magicWidthMargin: CGFloat = 4
		let frameWidth = frame.width - magicWidthMargin
		if let editor = currentEditor() {
			self.text = editor.string
		}
		let size = sizeThatFits(NSSize(width: frameWidth, height: 1000000))
		return NSSize(width: NSView.noIntrinsicMetric, height: size.height)
	}

	public override var frame: NSRect {
		didSet {
			if frame.width != oldValue.width {
				invalidateIntrinsicContentSize()
			}
		}
	}

	public func textView(_ textView: NSTextView, shouldChangeTextInRanges affectedRanges: [NSValue], replacementStrings: [String]?) -> Bool {
		invalidateIntrinsicContentSize()
		DispatchQueue.main.async {
			// scroll to the current insertion point
			// this is normally done automatically, but for some reason it fails when inside an form scroll view.
			guard textView.window == self.window else { return }
			let selectedRange = textView.selectedRange()
			guard selectedRange.location != NSNotFound && selectedRange.length == 0 else { return }
			var rectCount = 0
			let rectArray = textView.layoutManager?.rectArray(forCharacterRange: selectedRange, withinSelectedCharacterRange: selectedRange, in: textView.textContainer!, rectCount: &rectCount)
			if let rectArray = rectArray, rectCount > 0 {
				let textContainerOrigin = textView.textContainerOrigin
				let selectedRect = rectArray[0].offsetBy(dx: textContainerOrigin.x, dy: textContainerOrigin.y)
				self.scrollToVisible(self.convert(selectedRect, from: textView).insetBy(dx: 0, dy: -8))
			}
		}
		return true
	}

	open override func textDidChange(_ notification: Notification) {
		super.textDidChange(notification)
		onEditingCallback?(self)
	}

	@usableFromInline
	internal var onEditingCallback: ((MFTextField) -> ())?

}

extension MFTextField: MFEditable {
	public var editableValue: String {
		get { text ?? "" }
		set { text = newValue }
	}
	public func onEditing(_ callback: @escaping (String) -> ()) -> Self {
		onEditing { callback($0.editableValue) }
	}
}
#else
import UIKit

public class MFTextField: UITextField {
	// unimplemented
}
extension MFTextField: MFEditable {
	public var editableValue: String {
		get { text ?? "" }
		set { text = newValue }
	}
	public func onEditing(_ callback: @escaping (String) -> ()) -> Self {
		onChange { callback($0.editableValue) }
	}
}
#endif

