@resultBuilder
public struct UXSingleViewControllerBuilder {
	public static func buildBlock(_ view: UXKit.UXViewController) -> UXKit.UXViewController {
		view
	}
}

@resultBuilder
public struct UXSingleWindowBuilder {
	public static func buildBlock(_ view: UXWindow) -> UXWindow {
		view
	}
}
