import UXKit
#if os(macOS)
import AppKit
#else
import UIKit
#endif

extension UXLayoutConstraint {

	#if os(macOS)
	#else
	public typealias Priority = UILayoutPriority
	#endif

	public func withPriority(_ priority: Priority) -> Self {
		self.priority = priority
		return self
	}

}
