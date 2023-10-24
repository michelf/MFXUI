
//#if DEBUG
//import SwiftUI
//extension UXKit.UXViewController {
//	@available(macOS 10.15, *)
//	public var previewRepresentable: some View {
//#if os(macOS)
//		struct ViewRepresentable<ViewController: UXKit.UXViewController>: NSViewControllerRepresentable {
//			let viewController: ViewController
//			func makeNSViewController(context: Context) -> ViewController {
//				viewController
//			}
//			func updateNSViewController(_ nsViewController: ViewController, context: Context) {
//			}
//		}
//#else
//		struct ViewRepresentable<ViewController: UXKit.UXViewController>: UIViewControllerRepresentable {
//			let viewController: ViewController
//			func makeUIViewController(context: Context) -> ViewController {
//				viewController
//			}
//			func updateUIViewController(_ viewController: ViewController, context: Context) {
//			}
//		}
//#endif
//		return ViewRepresentable(viewController: self)
//	}
//}
//#endif
