import Foundation
import UXKit

extension NSObjectProtocol where Self: UXView {

	public func constrainingSize(width: UXFloat?, height: UXFloat?) -> Self {
		self.translatesAutoresizingMaskIntoConstraints = false
		if let width {
			addConstraint(widthAnchor.constraint(equalToConstant: width))
		}
		if let height {
			addConstraint(heightAnchor.constraint(equalToConstant: height))
		}
		return self
	}

	public func constrainingMaxSize(width: UXFloat?, height: UXFloat?) -> Self {
		self.translatesAutoresizingMaskIntoConstraints = false
		if let width {
			addConstraint(widthAnchor.constraint(lessThanOrEqualToConstant: width))
		}
		if let height {
			addConstraint(heightAnchor.constraint(lessThanOrEqualToConstant: height))
		}
		return self
	}

	public func constrainingMinSize(width: UXFloat?, height: UXFloat?) -> Self {
		self.translatesAutoresizingMaskIntoConstraints = false
		if let width {
			addConstraint(widthAnchor.constraint(greaterThanOrEqualToConstant: width))
		}
		if let height {
			addConstraint(heightAnchor.constraint(greaterThanOrEqualToConstant: height))
		}
		return self
	}

	public func withFlexibility(horizontal: Bool?, vertical: Bool?) -> Self {
		switch horizontal {
		case true:
			setContentHuggingPriority(.init(1), for: .horizontal)
			setContentCompressionResistancePriority(.init(1), for: .horizontal)
		case false:
			setContentHuggingPriority(.required, for: .horizontal)
			setContentCompressionResistancePriority(.required, for: .horizontal)
		default:
			break
		}
		switch vertical {
		case true:
			setContentHuggingPriority(.init(1), for: .vertical)
			setContentCompressionResistancePriority(.init(1), for: .vertical)
		case false:
			setContentHuggingPriority(.required, for: .vertical)
			setContentCompressionResistancePriority(.required, for: .vertical)
		default:
			break
		}
		return self
	}

}

extension NSObjectProtocol where Self: UXView {

	internal func withoutAutoresizingMaskConstraints() -> Self {
		translatesAutoresizingMaskIntoConstraints = false
		return self
	}

	internal func withFlexibility(alongAxis axis: UXStackViewAxis) -> Self {
		switch axis {
		case .horizontal:
			return withFlexibility(horizontal: true, vertical: false)
		case .vertical:
			return withFlexibility(horizontal: false, vertical: true)
		@unknown default:
			assert(false, "Unknown axis \(axis).")
			return self
		}
	}

}
