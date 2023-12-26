import Foundation

extension NSObjectProtocol where Self: UXView {

	public func withBackground(color: UXColor) -> UXView {
		#if os(macOS)
		return UXView.box(border: nil, fill: color) {
			self
		}
		#else
		self.backgroundColor = color
		return self
		#endif
	}

}
