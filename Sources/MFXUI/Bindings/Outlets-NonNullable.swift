import Foundation

// MARK: Non-nullable Outlet

extension NSObjectProtocol where Self: UXView {

	public func connecting(to outlet: inout Self, file: StaticString = #fileID, line: UInt = #line) -> Self {
		outlet = self
		return self
	}

	public func connecting<T>(_ keyPath: KeyPath<Self, T>, to outlet: inout T, file: StaticString = #fileID, line: UInt = #line) -> Self {
		outlet = self[keyPath: keyPath]
		return self
	}

}

#if os(macOS)
extension NSObjectProtocol where Self: UXScrollView {

	public func connectingContentView<T: UXView>(to outlet: inout T, file: StaticString = #fileID, line: UInt = #line) -> Self {
		assert(documentView != nil, "Missing documentView in \(Self.self).", file: file, line: line)
		assert(documentView is T, "Incompatible oultet type \(T.self) for scroll view content \(self.documentView!).", file: file, line: line)
		if let documentView = documentView as? T {
			outlet = documentView
		}
		return self
	}

}
#else
extension NSObjectProtocol where Self: UXScrollView {

	public func connectingContentView(to outlet: inout Self, file: StaticString = #fileID, line: UInt = #line) -> Self {
		outlet = self
		return self
	}

}
#endif
