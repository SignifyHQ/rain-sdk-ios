import Combine
import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide
import PassKit

// SwiftUI-based Add to Wallet button with custom styling
struct CustomAddToWalletButtonView: View {
  let configuration: PKAddPaymentPassRequestConfiguration
  let onTokenization: ([Data], Data, Data) async throws -> PKAddPaymentPassRequest?
  let onSuccess: () -> Void
  let onError: (Error) -> Void
  
  @State private var showPaymentPass = false
  
  var body: some View {
    Button(action: {
      // Check provisioning before presenting
      guard PKAddPaymentPassViewController.canAddPaymentPass(),
            PKAddPaymentPassViewController(requestConfiguration: configuration, delegate: nil) != nil else {
        log.error("Provisioning not available on this device.")
        onError(NSError(domain: "PaymentPass", code: -1, userInfo: [NSLocalizedDescriptionKey: "Provisioning not available on this device."]))
        return
      }
      
      showPaymentPass = true
    }) {
      HStack(spacing: 10) {
        Text(L10N.Common.AddToCardView.AddToWallet.Button.title)
          .font(Fonts.medium.swiftUIFont(size: Constants.FontSize.small.value))
          .foregroundColor(Colors.textPrimary.swiftUIColor)
        
        GenImages.Images.icoAppleWallet.swiftUIImage
          .resizable()
          .frame(width: 24, height: 18)
      }
      .frame(height: 48)
      .frame(maxWidth: .infinity)
      .background(Colors.buttonSurfaceTertiaryDefault.swiftUIColor)
      .cornerRadius(24)
    }
    .fullScreenCover(isPresented: $showPaymentPass) {
      PaymentPassViewControllerWrapper(
        configuration: configuration,
        onTokenization: onTokenization,
        onSuccess: {
          showPaymentPass = false
          onSuccess()
        },
        onError: { error in
          showPaymentPass = false
          onError(error)
        },
        onDismiss: {
          showPaymentPass = false
        }
      )
    }
  }
}

// UIKit wrapper for PKAddPaymentPassViewController
struct PaymentPassViewControllerWrapper: UIViewControllerRepresentable {
  let configuration: PKAddPaymentPassRequestConfiguration
  let onTokenization: ([Data], Data, Data) async throws -> PKAddPaymentPassRequest?
  let onSuccess: () -> Void
  let onError: (Error) -> Void
  let onDismiss: () -> Void
  
  func makeUIViewController(context: Context) -> UIViewController {
    let coordinator = context.coordinator
    
    guard let vc = PKAddPaymentPassViewController(requestConfiguration: configuration, delegate: coordinator) else {
      log.error("Provisioning not available on this device.")
      // Dismiss immediately and call error handler
      DispatchQueue.main.async {
        onError(NSError(domain: "PaymentPass", code: -1, userInfo: [NSLocalizedDescriptionKey: "Provisioning not available on this device."]))
        onDismiss()
      }
      // Return a transparent view controller that will be dismissed immediately
      let emptyVC = UIViewController()
      emptyVC.view = UIView()
      emptyVC.view.backgroundColor = .clear
      return emptyVC
    }
    
    coordinator.viewController = vc
    return vc
  }
  
  static func dismantleUIViewController(_ uiViewController: UIViewController, coordinator: Coordinator) {
    // Clean up if needed
  }
  
  func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    // No updates needed
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(
      configuration: configuration,
      onTokenization: onTokenization,
      onSuccess: onSuccess,
      onError: onError
    )
  }
  
  class Coordinator: NSObject, PKAddPaymentPassViewControllerDelegate {
    let configuration: PKAddPaymentPassRequestConfiguration
    let onTokenization: ([Data], Data, Data) async throws -> PKAddPaymentPassRequest?
    let onSuccess: () -> Void
    let onError: (Error) -> Void
    weak var viewController: PKAddPaymentPassViewController?
    
    init(
      configuration: PKAddPaymentPassRequestConfiguration,
      onTokenization: @escaping ([Data], Data, Data) async throws -> PKAddPaymentPassRequest?,
      onSuccess: @escaping () -> Void,
      onError: @escaping (Error) -> Void
    ) {
      self.configuration = configuration
      self.onTokenization = onTokenization
      self.onSuccess = onSuccess
      self.onError = onError
    }
    
    // MARK: - PKAddPaymentPassViewControllerDelegate
    
    func addPaymentPassViewController(
      _ controller: PKAddPaymentPassViewController,
      generateRequestWithCertificateChain certificates: [Data],
      nonce: Data,
      nonceSignature: Data,
      completionHandler handler: @escaping (PKAddPaymentPassRequest) -> Void
    ) {
      Task { @MainActor in
        do {
          guard let request = try await onTokenization(certificates, nonce, nonceSignature) else {
            log.error("Tokenization returned nil request.")
            handler(PKAddPaymentPassRequest())
            return
          }
          handler(request)
        } catch {
          log.error("Tokenization error: \(error.localizedDescription)")
          onError(error)
          handler(PKAddPaymentPassRequest())
        }
      }
    }
    
    func addPaymentPassViewController(
      _ controller: PKAddPaymentPassViewController,
      didFinishAdding pass: PKPaymentPass?,
      error: Error?
    ) {
      if let error = error {
        onError(error)
      } else if pass != nil {
        onSuccess()
      }
    }
  }
}
