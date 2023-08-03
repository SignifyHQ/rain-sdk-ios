import SwiftUI
import UIKit
import NetspendSdk
import LFUtilities

public struct NetspendLocationViewController: UIViewControllerRepresentable {
  
  var onClose: (() -> Void)?
  let withPasscode: String
  public init(withPasscode: String, onClose: (() -> Void)? = nil) {
    self.withPasscode = withPasscode
    self.onClose = onClose
  }
  
  public func makeUIViewController(context: Context) -> UIViewController {
    if let netspendViewController = try? NetspendSdk.shared.openWithPurpose(
      purpose: "locations",
      withPasscode: withPasscode,
      usingParams: [:]
    ) {
      netspendViewController.delegate = context.coordinator
      return netspendViewController
    }
    return UIViewController()
  }
  
  public func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
      // Update the view controller if needed
  }
}

extension NetspendLocationViewController {
  public class Coordinator: NSObject, NetspendSdkViewControllerDelegate {
    var parent: NetspendLocationViewController
    
    init(_ parent: NetspendLocationViewController) {
      self.parent = parent
    }
    
    public func netspendSdkViewController(_ viewController: NetspendSdkViewController, didChange state: NetspendSdkPurposeState) {
      log.debug(state)
    }
    
    public func netspendSdkViewController(_ viewController: NetspendSdkViewController, didEvent event: NetspendSdkPurposeEvent) {
      log.debug(event.name)
    }
    
    public func netspendSdkViewController(_ viewController: NetspendSdkViewController, didEncounterFatalError errorMessage: String) {
      if let dict = errorMessage.data(using: .utf8)?.convertToJsonDictionary(),
         let message = dict["message"] as? String, message == "AuthError" {
        parent.onClose?()
      }
      log.error(errorMessage)
    }
  }
}
