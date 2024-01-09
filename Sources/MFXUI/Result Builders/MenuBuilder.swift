import UXKit

#if os(macOS)
import AppKit
#else
import UIKit
#endif

// Adapted from ArrayElementListBuilder in SwiftSyntax/SwiftSyntaxBuilder

@available(tvOS 17.0, *)
public struct MFMenuSection<Value: Equatable> {
	public var title: String?
	public var children: [UXMenuElement]
	public init(title: String? = nil, @MFMenuBuilder<Value> children: () -> [UXMenuElement]) {
		self.title = title
		self.children = children()
	}
}
@available(tvOS 17.0, *)
public struct MFSubmenu<Value: Equatable> {
	public var title: String
	public var children: [UXMenuElement]
	public init(title: String, @MFMenuBuilder<Value> children: () -> [UXMenuElement]) {
		self.title = title
		self.children = children()
	}
}
@available(tvOS 17.0, *)
public struct MFOption<Value: Equatable> {
	public var title: String
	public var value: Value
	public init(title: String, value: Value) {
		self.title = title
		self.value = value
	}
}

@available(tvOS 17.0, *)
@resultBuilder
public struct MFMenuBuilder<Value: Equatable> {
	/// The type of individual statement expressions in the transformed function,
	/// which defaults to Component if buildExpression() is not provided.
	public typealias Expression = UXMenuElement

	/// The type of a partial result, which will be carried through all of the
	/// build methods.
	public typealias Component = [Expression]

	/// The type of the final returned result, which defaults to Component if
	/// buildFinalResult() is not provided.
	public typealias FinalResult = [UXMenuElement]

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
	public static func buildExpression(_ section: MFMenuSection<Value>) -> Self.Component {
#if os(macOS)
		// flatten section
		var items = section.children
		items.insert(.separator(), at: 0)
		if let title = section.title {
			items.insert(.sectionHeader_stub(title: title), at: 1)
		}
		return items
#else
		return [UIMenu(title: section.title ?? "", options: .displayInline, children: section.children)]
#endif
	}
	public static func buildExpression(_ submenu: MFSubmenu<Value>) -> Self.Component {
#if os(macOS)
		let menu = NSMenu()
		menu.items = submenu.children
		let item = NSMenuItem(title: submenu.title, action: nil, keyEquivalent: "")
		item.submenu = menu
		return [item]
#else
		return [UIMenu(title: submenu.title, children: submenu.children)]
#endif
	}
	public static func buildExpression(_ option: MFOption<Value>) -> Self.Component {
		[UXAction(title: option.title, _value: option.value)]
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
		#if os(macOS)
		return component.flatMap { item in
			// flatten separators with submenus (used to designate sections)
			if item.isSeparatorItem, let submenu = item.submenu {
				var items = submenu.items
				items.insert(.separator(), at: 0)
				if !submenu.title.isEmpty {
					items.insert(.sectionHeader_stub(title: submenu.title), at: 1)
				}
				return items
			} else {
				return [item]
			}
		}
		#else
		return component
		#endif
	}
}

#if os(macOS)
import AppKit
extension NSMenuItem {

	static func sectionHeader_stub(title: String) -> NSMenuItem {
		if #available(macOS 14, *) {
			return .sectionHeader(title: title)
		} else {
			// using incompatible action and target that will always result in an always-disabled item
			// (and that if ever invoked will do nothing)
			let item = NSMenuItem(title: "", action: #selector(getter: NSApplication.orderedWindows), keyEquivalent: "")
			item.target = self
			item.isEnabled = false
			item.attributedTitle = NSAttributedString(string: title, attributes: [
				.font: NSFont.systemFont(ofSize: 11, weight: .bold)
			])
			return item
		}
	}

}
#endif
