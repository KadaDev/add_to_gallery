import Flutter
import UIKit
import Photos

public class SwiftAddToGalleryPlugin: NSObject, FlutterPlugin {

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "add_to_gallery", binaryMessenger: registrar.messenger())
        let instance = SwiftAddToGalleryPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(
        _ call: FlutterMethodCall,
        result: @escaping FlutterResult
    ) {
        if call.method == "addToGallery" {
            self.addToAssetCollection(call, result)
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func addToAssetCollection(
        _ call: FlutterMethodCall,
        _ result: @escaping FlutterResult
    ) {
        let permissionStatus: PHAuthorizationStatus
        if #available(iOS 14, *) {
            permissionStatus = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        } else {
            permissionStatus = PHPhotoLibrary.authorizationStatus()
        }
        if permissionStatus != .authorized {
            result(FlutterError(code: "permissions", message: "Please grant PHPhotoLibrary permission", details: nil))
        } else {
            let args = call.arguments as? Dictionary<String, Any>
            let imagePath = args!["path"] as! String
            self.addFileToAssetCollection(imagePath, result)
        }
    }
    
    private func addFileToAssetCollection(
        _ imagePath: String,
        _ result: @escaping FlutterResult
    ) {
        let url = URL(fileURLWithPath: imagePath)
        PHPhotoLibrary.shared().performChanges({
            let assetCreationRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: url)
        }) { (success, error) in
            if success {
                result(imagePath) // Success!
            } else {
                result(FlutterError(code: "could_not_save_file", message: "Could Not Save File", details: nil))
            }
        }
    }
}
