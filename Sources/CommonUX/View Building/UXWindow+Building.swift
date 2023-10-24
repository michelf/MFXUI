#if os(macOS)
import AppKit

extension UXWindow {

	public convenience init(title: String = "", closable: Bool, miniaturizable: Bool, resizable: Bool, hidesOnDeactivate: Bool = false, @UXSingleViewControllerBuilder content: () -> UXKit.UXViewController) {
		self.init(contentViewController: content())
		self.title = title
		if !closable {
			self.styleMask.remove(.closable)
		}
		if !miniaturizable {
			self.styleMask.remove(.miniaturizable)
		}
		if !resizable {
			self.styleMask.remove(.resizable)
		}
		self.hidesOnDeactivate = hidesOnDeactivate
	}

}

extension NSWindowController {

	public convenience init(@UXSingleWindowBuilder content: @escaping () -> UXWindow) {
		self.init()
		self.window = content()
	}

}

#endif
