
extension UXImageView {

	public convenience init(image: UXImage?, tint: UXColor? = nil) {
		self.init()
		self.image = image
		if let tint {
			#if os(macOS)
			if #available(macOS 10.14, *) {
				self.contentTintColor = tint
			}
			#else
			self.tintColor = tint
			#endif
		}
		self.translatesAutoresizingMaskIntoConstraints = false
	}

}

