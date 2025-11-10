import Flutter
import UIKit
import GWIoTApi

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        demoHomeSetup()
    
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    
    func demoHomeSetup() {
        let flutterViewController : FlutterViewController = window?.rootViewController as! FlutterViewController
        AppDelegateShadow.shadowConfigureFlutterEngine(viewController: flutterViewController)
        navigationSetup(flutterViewController: flutterViewController)
    }
    
    func navigationSetup(flutterViewController: FlutterViewController) {
        let navigationController = CustomUINavigationController(rootViewController: flutterViewController)
        navigationController.setNavigationBarHidden(false, animated: false)
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = navigationController
        
        setUniversalNativeBackIcon()
    }
    
    func setUniversalNativeBackIcon() {
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground() // Or .configureWithTransparentBackground() etc.

            // Define your desired icon size and weight
            let pointSize: CGFloat = 16
            let iconWeight: UIImage.SymbolWeight = .regular
            let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: pointSize, weight: iconWeight)

            // Get the base SF Symbol
            guard let baseBackArrowImage = UIImage(systemName: "chevron.backward", withConfiguration: symbolConfiguration) else {
                NSLog("Error: Could not load base SF Symbol 'chevron.backward'.")
                return
            }

            // --- Core Change: Create a new image with padding ---
            let leftPadding: CGFloat = 12.0 // The amount to move the icon to the right (desired left padding)
            let bottomPadding: CGFloat = 12.0
            let imageSize = baseBackArrowImage.size
            
            // Calculate the new size of the image canvas including the padding
            let paddedImageSize = CGSize(width: imageSize.width + leftPadding, height: imageSize.height + bottomPadding)

            // Create a new image by drawing the original icon onto a larger transparent canvas
            UIGraphicsBeginImageContextWithOptions(paddedImageSize, false, baseBackArrowImage.scale)
            baseBackArrowImage.draw(at: CGPoint(x: leftPadding, y: bottomPadding)) // Draw the icon offset by the padding
            let customBackArrowImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            // --- End Core Change ---

            // Ensure the new image is treated as a template for tinting
            let templatedCustomBackArrowImage = customBackArrowImage?.withRenderingMode(.alwaysTemplate)

            // Set custom indicator icon
            if let finalImage = templatedCustomBackArrowImage {
                appearance.setBackIndicatorImage(finalImage, transitionMaskImage: finalImage)
            } else {
                NSLog("Error: Failed to create padded back arrow image.")
                // Optionally, fall back to the unpadded image or system default
                appearance.setBackIndicatorImage(baseBackArrowImage, transitionMaskImage: baseBackArrowImage)
            }
            
            // Set color
            UINavigationBar.appearance().tintColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)

            // Set text color to be transparent
            appearance.backButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]

            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().compactAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        } else {
            // Fallback for older iOS versions if needed (less common now)
            // For image:
            UINavigationBar.appearance().backIndicatorImage = UIImage(systemName: "chevron.backward")
            UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage(systemName: "chevron.backward")
            // For text:
            UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset(horizontal: -1000, vertical: 0), for: .default)
            // For tint color on older versions
            UINavigationBar.appearance().tintColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        }
    }
    
}
