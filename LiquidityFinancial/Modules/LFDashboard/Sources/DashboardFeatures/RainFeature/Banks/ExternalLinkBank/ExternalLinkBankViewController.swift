import SwiftUI
import NetspendSdk
import LFUtilities

struct ExternalLinkBankViewController: UIViewControllerRepresentable {
  typealias UIViewControllerType = NetspendSdkViewController
  let controller: NetspendSdkViewController
  let onSuccess: (() -> Void)?
  let onFailure: (() -> Void)?
  let onCancelled: (() -> Void)?
  
  init(
    controller: NetspendSdkViewController,
    onSuccess: (() -> Void)? = nil,
    onFailure: (() -> Void)? = nil,
    onCancelled: (() -> Void)? = nil
  ) {
    self.controller = controller
    self.onSuccess = onSuccess
    self.onFailure = onFailure
    self.onCancelled = onCancelled
  }
  
  func makeUIViewController(context: Context) -> NetspendSdkViewController {
    controller.delegate = context.coordinator
    return controller
  }
  
  func updateUIViewController(_ uiViewController: NetspendSdkViewController, context: Context) {
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
}

// MARK: - Coordinator
extension ExternalLinkBankViewController {
  class Coordinator: NSObject, NetspendSdkViewControllerDelegate {
    let parent: ExternalLinkBankViewController
    
    init(_ parent: ExternalLinkBankViewController) {
      self.parent = parent
    }
    
    func netspendSdkViewController(_ viewController: NetspendSdkViewController, didEvent event: NetspendSdkPurposeEvent) {
      log.info("NetSpend Event \(event)")
      if Constants.netSpendSDKLinkBankErrors.contains(event.name) {
        parent.onFailure?()
      }
    }
    
    func netspendSdkViewController(_ viewController: NetspendSdkViewController, didChange state: NetspendSdkPurposeState) {
      log.info("NetSpend State \(state)")
      switch state {
      case .cancelled:
        parent.onCancelled?()
      case .success:
        parent.onSuccess?()
      case .error:
        parent.onFailure?()
      default:
        break
      }
    }
    
    func netspendSdkViewController(_ viewController: NetspendSdkViewController, didEncounterFatalError errorMessage: String) {
      log.info("NetSpend error \(errorMessage)")
    }
  }
}
