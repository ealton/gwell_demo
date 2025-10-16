class AppDelegateShadow {
    
    static var flutterViewController: FlutterViewController?
    static var mainAppDelegate: FlutterAppDelegate?
    static var vendorMethodChannelController: VendorMethodChannelController?
    
    static func shadowInit(appDelegate: FlutterAppDelegate) {
        mainAppDelegate = appDelegate
    }
    
    static func shadowConfigureFlutterEngine(viewController: FlutterViewController) {
        flutterViewController = viewController
        vendorMethodChannelController = VendorMethodChannelController()
        vendorMethodChannelController!.registerVendorMethodChannel(
                flutterViewController: flutterViewController!
            )
    }
    
}
