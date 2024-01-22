import SwiftUI
import UIKit
import NetspendSdk
import LFUtilities

public struct NetspendDisputeTransactionViewController: UIViewControllerRepresentable {
  
  var onClose: (() -> Void)?
  let netspendAccountID: String
  let passcode: String
  
  public init(netspendAccountID: String, passcode: String, onClose: (() -> Void)? = nil) {
    self.netspendAccountID = netspendAccountID
    self.passcode = passcode
    self.onClose = onClose
  }
  
  public func makeUIViewController(context: Context) -> UIViewController {
    if let netspendViewController = try? NetspendSdk.shared.openWithPurpose(purpose: .disputeLean, withPasscode: passcode, usingParams: [
      "accountId": netspendAccountID
    ]) {
      netspendViewController.delegate = context.coordinator
      return netspendViewController
    }
    return UIViewController()
  }
  
  public func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
  }
}

extension NetspendDisputeTransactionViewController {
  public class Coordinator: NSObject, NetspendSdkViewControllerDelegate {
    var parent: NetspendDisputeTransactionViewController
    
    init(_ parent: NetspendDisputeTransactionViewController) {
      self.parent = parent
    }
    
    public func netspendSdkViewController(_ viewController: NetspendSdkViewController, didChange state: NetspendSdkPurposeState) {
      log.info("NetSpend State \(state)")
      switch state {
      case .cancelled:
        parent.onClose?()
      case .error:
        parent.onClose?()
      case .success:
        parent.onClose?()
      default:
        break
      }
    }
    
    public func netspendSdkViewController(_ viewController: NetspendSdkViewController, didEvent event: NetspendSdkPurposeEvent) {
      log.info("NetSpend Event \(event)")
    }
    
    public func netspendSdkViewController(_ viewController: NetspendSdkViewController, didEncounterFatalError errorMessage: String) {
      log.info("NetSpend error \(errorMessage)")
      parent.onClose?()
    }
  }
}
