import UXKit

// Adapted from ArrayElementListBuilder in SwiftSyntax/SwiftSyntaxBuilder

@resultBuilder
public struct UXViewBuilder {
	/// The type of individual statement expressions in the transformed function,
	/// which defaults to Component if buildExpression() is not provided.
	public typealias Expression = UXView

	/// The type of a partial result, which will be carried through all of the
	/// build methods.
	public typealias Component = [Expression]

	/// The type of the final returned result, which defaults to Component if
	/// buildFinalResult() is not provided.
	public typealias FinalResult = [UXView]

	/// Required by every result builder to build combined results from
	/// statement blocks.
	public static func buildBlock(_ components: Self.Component...) -> Self.Component {
		return components.flatMap {
			$0
		}
	}

	/// If declared, provides contextual type information for statement
	/// expressions to translate them into partial results.
	public static func buildExpression(_ expression: Self.Expression) -> Self.Component {
		return [expression]
	}

	/// Add all the elements of `expression` to this result builder, effectively flattening them.
	public static func buildExpression(_ expression: Self.FinalResult) -> Self.Component {
		return expression.map {
			$0
		}
	}

	/// Enables support for `if` statements that do not have an `else`.
	public static func buildOptional(_ component: Self.Component?) -> Self.Component {
		return component ?? []
	}

	/// With buildEither(second:), enables support for 'if-else' and 'switch'
	/// statements by folding conditional results into a single result.
	public static func buildEither(first component: Self.Component) -> Self.Component {
		return component
	}

	/// With buildEither(first:), enables support for 'if-else' and 'switch'
	/// statements by folding conditional results into a single result.
	public static func buildEither(second component: Self.Component) -> Self.Component {
		return component
	}

	/// Enables support for 'for..in' loops by combining the
	/// results of all iterations into a single result.
	public static func buildArray(_ components: [Self.Component]) -> Self.Component {
		return components.flatMap {
			$0
		}
	}

	/// If declared, this will be called on the partial result of an 'if'
	/// #available' block to allow the result builder to erase type
	/// information.
	public static func buildLimitedAvailability(_ component: Self.Component) -> Self.Component {
		return component
	}

	/// If declared, this will be called on the partial result from the outermost
	/// block statement to produce the final returned result.
	public static func buildFinalResult(_ component: Component) -> FinalResult {
		return component
	}
}
