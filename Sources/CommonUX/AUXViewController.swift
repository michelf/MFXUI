#if os(macOS)
import AppKit

open class AUXViewController: NSViewController {

	// Replace AppKit hooks with equivalents from UIKit.

	public final override func viewWillAppear() { viewWillAppear(false) }
	public final override func viewDidAppear() { viewDidAppear(false) }
	public final override func viewWillDisappear() { viewWillDisappear(false) }
	public final override func viewDidDisappear() { viewDidDisappear(false) }
	public final override func viewWillLayout() { viewWillLayoutSubviews() }
	public final override func viewDidLayout() { viewDidLayoutSubviews() }

	open func viewWillAppear(_ animated: Bool) { super.viewWillAppear() }
	open func viewDidAppear(_ animated: Bool) { super.viewDidAppear() }
	open func viewWillDisappear(_ animated: Bool) { super.viewWillDisappear() }
	open func viewDidDisappear(_ animated: Bool) { super.viewDidDisappear() }
	open func viewWillLayoutSubviews() { super.viewWillLayout() }
	open func viewDidLayoutSubviews() { super.viewDidLayout() }

}

#else
import UIKit

public typealias AUXViewController = UIViewController
#endif
