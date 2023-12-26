#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension UXFont {

#if os(macOS)
	private static let regularSize: UXFloat = UXFont.systemFontSize(for: .regular)
	private static let mediumSize: UXFloat = (regularSize + smallSize)/2  // average
	private static let smallSize: UXFloat = UXFont.systemFontSize(for: .small)
	private static let miniSize: UXFloat = UXFont.systemFontSize(for: .mini)
#else
	private static let regularSize: UXFloat = headline.pointSize
	private static let mediumSize: UXFloat = callout.pointSize
	private static let smallSize: UXFloat = subheadline.pointSize
	private static let miniSize: UXFloat = footnote.pointSize
#endif

	public static func regular(weight: UXFont.Weight = .regular) -> UXFont {
		systemFont(ofSize: regularSize, weight: weight)
	}
	public static func medium(weight: UXFont.Weight = .regular) -> UXFont {
		systemFont(ofSize: mediumSize, weight: weight)
	}
	public static func small(weight: UXFont.Weight = .regular) -> UXFont {
		systemFont(ofSize: smallSize, weight: weight)
	}
	public static func mini(weight: UXFont.Weight = .regular) -> UXFont {
		systemFont(ofSize: miniSize, weight: weight)
	}

	// MARK: Shortcuts to standard Apple text styles
	// includes fallbacks for older macOS versions

	@available(tvOS, unavailable)
	public static var largeTitle: UXFont {
		#if !os(tvOS)
		if #available(macOS 11, *) { return UXFont.preferredFont(forTextStyle: .largeTitle) }
		#endif
		return UXFont.systemFont(ofSize: 26)
	}
	public static var title1: UXFont {
		if #available(macOS 11, *) { return UXFont.preferredFont(forTextStyle: .title1) }
		return UXFont.systemFont(ofSize: 22)
	}
	public static var title2: UXFont {
		if #available(macOS 11, *) { return UXFont.preferredFont(forTextStyle: .title2) }
		return UXFont.systemFont(ofSize: 17)
	}
	public static var title3: UXFont {
		if #available(macOS 11, *) { return UXFont.preferredFont(forTextStyle: .title3) }
		return UXFont.systemFont(ofSize: 15)
	}
	public static var headline: UXFont {
		if #available(macOS 11, *) { return UXFont.preferredFont(forTextStyle: .headline) }
		return UXFont.boldSystemFont(ofSize: 13)
	}
	public static var subheadline: UXFont {
		if #available(macOS 11, *) { return UXFont.preferredFont(forTextStyle: .subheadline) }
		return UXFont.systemFont(ofSize: 11)
	}
	public static var body: UXFont {
		if #available(macOS 11, *) { return UXFont.preferredFont(forTextStyle: .body) }
		return UXFont.systemFont(ofSize: 13)
	}
	public static var callout: UXFont {
		if #available(macOS 11, *) { return UXFont.preferredFont(forTextStyle: .callout) }
		return UXFont.systemFont(ofSize: 12)
	}
	public static var footnote: UXFont {
		if #available(macOS 11, *) { return UXFont.preferredFont(forTextStyle: .footnote) }
		return UXFont.systemFont(ofSize: 10)
	}
	public static var caption1: UXFont {
		if #available(macOS 11, *) { return UXFont.preferredFont(forTextStyle: .caption1) }
		return UXFont.systemFont(ofSize: 10)
	}
	public static var caption2: UXFont {
		if #available(macOS 11, *) { return UXFont.preferredFont(forTextStyle: .caption2) }
		return UXFont.systemFont(ofSize: 10, weight: .medium)
	}
}
