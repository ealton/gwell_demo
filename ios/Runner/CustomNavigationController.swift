import UIKit
import WebKit // Import if WebViewController is a WKWebView internally, or if you need to check for it

class CustomUINavigationController: UINavigationController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    override var shouldAutorotate: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self // Set yourself as the delegate
    }
    
    // Default Orientation
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return self.topViewController?.preferredInterfaceOrientationForPresentation ?? .portrait
    }

    // Supported Orientation
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        self.topViewController?.supportedInterfaceOrientations ?? .portrait
    }

    // MARK: - UINavigationControllerDelegate

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        let viewControllerTypeString = String(describing: type(of: viewController))
        let pagesRequiringNavBar = [
            "AlbumViewController",
            "DevicePermissionConfigurationViewController",
            "DeviceFirmwareUpgradeViewController",
            "IssueFeedbackH5ViewController",
            "ShareByFace2FaceViewController",
            "ShareDeviceConfirmViewController",
            "ShareFromManagedViewController",
            "ShareManagedViewController",
            "ShareToManagedViewController",
            "VASServiceWebViewController",
            "MessageCenterViewController",
            "MessageCenterSubLevelViewController",
            "WebViewController",
        ]
        if pagesRequiringNavBar.contains(viewControllerTypeString) {
            navigationController.setNavigationBarHidden(false, animated: animated)
        } else {
            navigationController.setNavigationBarHidden(true, animated: animated)
        }
        
        print("viewControllerType: \(viewControllerTypeString)")
        print("prefersStatusBarHidden: \(viewController.navigationController?.navigationBar.isHidden ?? true)")
        
    }
    
}
