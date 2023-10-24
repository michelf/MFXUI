import Foundation

// MARK: Nullable Outlet

extension NSObjectProtocol where Self: UXView {

	public func connecting(to outlet: inout Self?, file: StaticString = #fileID, line: UInt = #line) -> Self {
		assertOutletNotConnected(outlet, file: file, line: line)
		outlet = self
		return self
	}

	public func connecting<T>(_ keyPath: KeyPath<Self, T>, to outlet: inout T?, file: StaticString = #fileID, line: UInt = #line) -> Self {
		assertOutletNotConnected(outlet, file: file, line: line)
		outlet = self[keyPath: keyPath]
		return self
	}
	public func connecting<T>(_ keyPath: KeyPath<Self, T?>, to outlet: inout T?, file: StaticString = #fileID, line: UInt = #line) -> Self {
		assertOutletNotConnected(outlet, file: file, line: line)
		outlet = self[keyPath: keyPath]
		return self
	}

}

extension NSObjectProtocol where Self: UXScrollView {

	public func connectingContentView<T: UXView>(to outlet: inout T?, file: StaticString = #fileID, line: UInt = #line) -> Self {
		assertOutletNotConnected(outlet, file: file, line: line)
		#if os(macOS)
		let documentView = self.documentView
		#else
		let documentView = self as Self?
		#endif
		assert(documentView != nil, "Missing documentView in \(Self.self).", file: file, line: line)
		assert(documentView is T, "Incompatible oultet type \(T.self) for scroll view content \(documentView!).", file: file, line: line)
		if let documentView = documentView as? T {
			outlet = documentView
		}
		return self
	}

}

/// Runtime check that the outlet is not connected twice.
private func assertOutletNotConnected<T>(_ outlet: T?, file: StaticString = #fileID, line: UInt = #line) {
	assert(outlet == nil, "Outlet already connected.", file: file, line: line)
}
