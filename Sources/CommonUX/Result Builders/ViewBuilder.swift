import UXKit

@resultBuilder
public struct UXViewBuilder {

	public static func buildBlock(_ components: UXView...) -> [UXView] {
		components
	}

	public static func buildArray(_ components: [UXView]) -> [UXView] {
		components
	}

	public static func buildOptional(_ component: [UXView]?) -> [UXView] {
		component ?? []
	}

	public static func buildEither(first component: [UXView]) -> [UXView] {
		component
	}
	public static func buildEither(second component: [UXView]) -> [UXView] {
		component
	}

	public static func buildExpression(_ expression: UXView) -> UXView {
		expression
	}

	public static func buildLimitedAvailability(_ component: [UXView]) -> [UXView] {
		component
	}

	public static func buildFinalResult(_ component: [UXView]) -> [UXView] {
		component
	}
}
