import Flutter
import UIKit
import Security

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    let controller = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "com.example.mcal/certificates", binaryMessenger: controller.binaryMessenger)
    channel.setMethodCallHandler { (call, result) in
      if call.method == "getCACertificates" {
        do {
          let certificates = try self.getSystemCACertificates()
          result(certificates)
        } catch {
          print("Error reading CA certificates: \(error)")
          result([]) // Fallback to empty list
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func getSystemCACertificates() throws -> [String] {
    var certificates: [String] = []
    var anchors: CFArray?

    let status = SecTrustCopyAnchorCertificates(&anchors)
    guard status == errSecSuccess, let anchors = anchors as? [SecCertificate] else {
      throw NSError(domain: "CertificateError", code: Int(status), userInfo: nil)
    }

    for cert in anchors {
      if let pem = certificateToPEM(cert) {
        certificates.append(pem)
      }
    }

    return certificates
  }

  private func certificateToPEM(_ cert: SecCertificate) -> String? {
    guard let data = SecCertificateCopyData(cert) as Data? else { return nil }
    let base64 = data.base64EncodedString(options: .lineLength64Characters)
    return "-----BEGIN CERTIFICATE-----\n\(base64)\n-----END CERTIFICATE-----\n"
  }
}
