import Foundation
import PassKit
import SwiftUI
import LFLocalizable
import NetSpendData
import NetspendDomain
import Factory
import LFUtilities

struct RainApplePayViewController: UIViewControllerRepresentable {
  @Environment(\.presentationMode) var presentation
  @StateObject private var viewModel: RainApplePayViewModel
  
  var onSuccess: (() -> Void)?
  
  init(viewModel: RainApplePayViewModel, onSuccess: ( () -> Void)? = nil) {
    _viewModel = .init(wrappedValue: viewModel)
    self.onSuccess = onSuccess
  }
  
  func updateUIViewController(_: PKAddPaymentPassViewController, context _: Context) {}
  
  func makeUIViewController(context: Context) -> PKAddPaymentPassViewController {
    let request = PKAddPaymentPassRequestConfiguration(encryptionScheme: .ECC_V2)
    request?.cardholderName = viewModel.cardModel.cardholderName
    request?.primaryAccountSuffix = viewModel.cardModel.last4
    request?.localizedDescription = L10N.Common.AddToWallet.ApplePay.message
    request?.primaryAccountIdentifier = viewModel.cardModel.id
    request?.paymentNetwork = PKPaymentNetwork.visa
    if let request, let apm = PKAddPaymentPassViewController(requestConfiguration: request, delegate: context.coordinator) {
      return apm
    }
    return PKAddPaymentPassViewController()
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
}

extension RainApplePayViewController {
  class Coordinator: NSObject, PKAddPaymentPassViewControllerDelegate {
    var parent: RainApplePayViewController
    
    init(_ parent: RainApplePayViewController) {
      self.parent = parent
    }
    
    func addPaymentPassViewController(_: PKAddPaymentPassViewController, generateRequestWithCertificateChain certificates: [Data], nonce: Data, nonceSignature: Data, completionHandler handler: @escaping (PKAddPaymentPassRequest) -> Void) {
      if PKAddPaymentPassViewController.canAddPaymentPass() {
        Task { @MainActor in
          do {
            let paymentPassRequest = PKAddPaymentPassRequest()
            let certificateLeaf = certificates[0].base64EncodedString()
            let nonceString = nonce.base64EncodedString()
            let nonceSignatureVal = nonceSignature.base64EncodedString()
            var body: [String: Any] = [:]
            body["certificates"] = [certificateLeaf]
            body["nonce"] = nonceString
            body["nonceSignature"] = nonceSignatureVal
            if let cardData = try await parent.viewModel.callEnrollWalletAPI(bodyData: body) {
              
              let payloadData = cardData.encryptedCardData ?? .empty
              let activationcode = cardData.activationData ?? .empty
              let ephemeralkey = cardData.ephemeralPublicKey ?? .empty
              
              let encryptedPassData = Data(base64Encoded: payloadData, options: [])
              let ephemeralPublicKey = Data(base64Encoded: ephemeralkey, options: [])
              let activationData = Data(base64Encoded: activationcode, options: [])
              
              paymentPassRequest.activationData = activationData
              paymentPassRequest.encryptedPassData = encryptedPassData
              paymentPassRequest.ephemeralPublicKey = ephemeralPublicKey
              handler(paymentPassRequest)
            } else {
              handler(paymentPassRequest)
            }
          } catch {
            log.error(error.userFriendlyMessage)
          }
        }
      }
    }
    
    func addPaymentPassViewController(_: PKAddPaymentPassViewController, didFinishAdding _: PKPaymentPass?, error: Error?) {
      parent.presentation.wrappedValue.dismiss()
      if error == nil {
        parent.onSuccess?()
      }
    }
  }
}
