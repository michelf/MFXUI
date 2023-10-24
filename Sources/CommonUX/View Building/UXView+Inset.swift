
extension UXView {

	public func inset(by insets: UXEdgeInsets) -> UXView {
		#if os(macOS)
		// using NSStackView as a wrapper because it
		// doesn't clip its content
		let wrapper = UXStackView()
		#else
		let wrapper = UXView()
		#endif
		wrapper.addSubview(self)
		wrapper.addConstraints([
			topAnchor.constraint(equalTo: wrapper.topAnchor, constant: insets.top),
			bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -insets.bottom),
			leftAnchor.constraint(equalTo: wrapper.leftAnchor, constant: insets.left),
			rightAnchor.constraint(equalTo: wrapper.rightAnchor, constant: -insets.right),
		])
		return wrapper.withoutAutoresizingMaskConstraints()
	}
	
	public func insetBy(dx: UXFloat, dy: UXFloat) -> UXView {
		self.inset(by: UXEdgeInsets(top: dy, left: dx, bottom: dy, right: dx))
	}

	public func inset(by inset: UXFloat) -> UXView {
		self.insetBy(dx: inset, dy: inset)
	}

	public func centerHorizontal(insets: UXEdgeInsets?) -> UXView {
		let wrapper = UXView()
		wrapper.addSubview(self)
		wrapper.addConstraints([
			topAnchor.constraint(equalTo: wrapper.topAnchor, constant: insets?.top ?? 0),
			bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -(insets?.bottom ?? 0)),
			centerXAnchor.constraint(equalTo: wrapper.centerXAnchor),
			leftAnchor.constraint(greaterThanOrEqualTo: wrapper.leftAnchor, constant: max(insets?.right ?? 0, insets?.left ?? 0)),
		])
		return wrapper.withoutAutoresizingMaskConstraints()
	}

	public func insetCenterHorizontal(dx: UXFloat, dy: UXFloat) -> UXView {
		centerHorizontal(insets: UXEdgeInsets(top: dy, left: dx, bottom: dy, right: dx))
	}

}
