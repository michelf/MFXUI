@_exported import UXKit
//#if os(macOS)
//@_exported import AppKit
//#else
//@_exported import UIKit
//#endif

public typealias UXActivityIndicator = UXSpinner
public typealias UXProgressView = UXProgressBar

#if os(macOS)
import AppKit

public typealias UXEvent = NSEvent
public typealias UXApplication = NSApplication
public typealias UXApplicationDelegate = NSApplicationDelegate

public typealias UXTabBarController = NSTabViewController
public typealias UXSplitViewController = NSSplitViewController
public typealias UXBarButtonItem = NSButton
public typealias UXSegmentedControl = NSSegmentedControl
public typealias UXTableViewCell = NSTableCellView
public typealias UXStoryboardSegue = NSStoryboardSegue
public typealias UXStepper = NSStepper
@available(macOS 10.15, *)
public typealias UXSwitch = NSSwitch
public typealias UXAction = NSMenuItem
public typealias UXMenuElement = NSMenuItem

extension UXButton {

	public var isSelected: Bool {
		get { state == .on }
		set { state = newValue ? .on : .off }
	}

}
extension UXLabel {

	@objc open var text: String? {
		get { stringValue }
		set { stringValue = newValue ?? "" }
	}

}
extension UXView {

	public static func animate(withDuration duration: TimeInterval, animations: @escaping () -> ()) {
		NSAnimationContext.runAnimationGroup { context in
			NSAnimationContext.current.duration = duration
			NSAnimationContext.current.allowsImplicitAnimation = true

			animations()
		}
	}
	public static func animate(withDuration duration: TimeInterval, animations: @escaping () -> (), completion: @escaping (Bool) -> ()) {
		NSAnimationContext.runAnimationGroup {  context in
			NSAnimationContext.current.duration = duration
			NSAnimationContext.current.allowsImplicitAnimation = true

			animations()
		} completionHandler: {
			completion(true)
		}

	}

	public var alpha: CGFloat {
		get { alphaValue }
		set { alphaValue = newValue }
	}

	/// "Safe" version of isHidden that will avoid calling the setter if the value of isHidden does not change.
	/// This appears to solve issues when hiding views inside stack views
	public var isHiddenX: Bool {
		get { isHidden }
		set {
			guard isHidden != newValue else { return }
			isHidden = newValue
		}
	}

	public var isUsingDarkAppearance: Bool {
		if #available(macOS 10.14, *) {
			let match = effectiveAppearance.bestMatch(from: [.aqua, .darkAqua])
			return match == .darkAqua
		} else {
			return effectiveAppearance.name == .vibrantDark
		}
	}

}
extension UXSpinner {

	public func startAnimating() {
		startAnimation(nil)
	}
	public func stopAnimating() {
		stopAnimation(nil)
	}

}
extension IndexPath {

	public var row: Int { self[1] }
	public var section: Int { self[0] }

}
extension UXImage {
	@available(macOS 11, *)
	public convenience init?(systemName: String, accessibilityDescription: String? = nil) {
		self.init(systemSymbolName: systemName, accessibilityDescription: accessibilityDescription)
	}
	public convenience init(cgImage: CGImage) {
		let size = NSSize(width: cgImage.width, height: cgImage.height)
		self.init(cgImage: cgImage, size: size)
	}
	public var cgImage: CGImage? {
		self.cgImage(forProposedRect: nil, context: nil, hints: nil)
	}
}
extension UXKit.UXViewController {
	public func loadViewIfNeeded() {
		_ = view
	}
}
extension UXTableViewCell {
	@IBOutlet open var textLabel: UXLabel? {
		get { textField }
		set { textField = newValue }
	}
	@IBOutlet open var detailTextLabel: UXLabel? {
		get { nil }
		set { }
	}
}
extension UXStoryboardSegue {
	public var destination: UXKit.UXViewController! {
		destinationController as? UXKit.UXViewController
	}
}
extension UXSegmentedControl {
	public var selectedSegmentIndex: Int {
		get { indexOfSelectedItem }
		set {
			for index in 0..<segmentCount {
				setSelected(index == newValue, forSegment: index)
			}
		}
	}
}
extension UXSlider {
	public var minimumValue: Float {
		get { Float(minValue) }
		set { minValue = Double(newValue) }
	}
	public var maximumValue: Float {
		get { Float(maxValue) }
		set { maxValue = Double(newValue) }
	}
	public var value: Float {
		get { floatValue }
		set { floatValue = newValue }
	}
}
extension UXStepper {
	public var minimumValue: Double {
		get { minValue }
		set { minValue = newValue }
	}
	public var maximumValue: Double {
		get { maxValue }
		set { maxValue = newValue }
	}
	public var stepValue: Double {
		get { increment }
		set { increment = newValue }
	}
	public var value: Double {
		get { doubleValue }
		set { doubleValue = newValue }
	}
}

extension UXTextField {
	public var placeholder: String? {
		get { placeholderString }
		set { placeholderString = newValue }
	}
	public var attributedPlaceholder: NSAttributedString? {
		get { placeholderAttributedString }
		set { placeholderAttributedString = newValue }
	}
}

extension UXTextView {
	public var text: String {
		get { string }
		set { string = newValue }
	}
}

extension UXApplication {

	public func open(_ url: URL) {
		NSWorkspace.shared.open(url)
	}

}

extension UXColor {

	public convenience init(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
		self.init(calibratedHue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
	}

}

#endif

#if os(iOS) || os(tvOS)

import UIKit

public typealias UXEvent = UIEvent
public typealias UXApplication = UIApplication
public typealias UXApplicationDelegate = UIApplicationDelegate

public typealias UXWindow = UIWindow
public typealias UXTabBarController = UITabBarController
public typealias UXSplitViewController = UISplitViewController
public typealias UXDiffableDataSourceSnapshot = NSDiffableDataSourceSnapshot
public typealias UXImage = UIImage
public typealias UXDevice = UIDevice
public typealias UXBarButtonItem = UIBarButtonItem
public typealias UXSegmentedControl = UISegmentedControl
public typealias UXTableViewCell = UITableViewCell
public typealias UXLayoutConstraint = NSLayoutConstraint
public typealias UXLayoutGuide = UILayoutGuide
public typealias UXStoryboardSegue = UIStoryboardSegue
#if os(iOS)
public typealias UXSwitch = UISwitch // iOS only
public typealias UXStepper = UIStepper // iOS only
#endif
public typealias UXPopUp = UIButton
public typealias UXAction = UIAction
public typealias UXMenuElement = UIMenuElement

extension UXButton {

	public var image: UXImage? {
		get { image(for: .normal) }
		set { setImage(newValue, for: .normal) }
	}

}

extension UXView {

	/// "Safe" version of isHidden that will avoid calling the setter if the value of isHidden does not change.
	/// This appears to solve issues when hiding views inside stack views
	public var isHiddenX: Bool {
		get { isHidden }
		set {
			guard isHidden != newValue else { return }
			isHidden = newValue
		}
	}

	public var isUsingDarkAppearance: Bool {
		traitCollection.userInterfaceStyle == .dark
	}

}

extension UXApplication {

	public var isActive: Bool {
		applicationState == .active
	}

}

#endif
