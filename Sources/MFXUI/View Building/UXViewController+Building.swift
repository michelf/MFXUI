
extension UXViewController {

	public convenience init(@UXSingleViewBuilder content: @escaping () -> UXView) {
		self.init()
		self.view = content()
	}

}
