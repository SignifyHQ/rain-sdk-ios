import Foundation
import PassKit
import SwiftUI
import LFLocalizable
import NetSpendData
import NetspendDomain
import Factory
import LFUtilities

public struct ApplePayViewController: UIViewControllerRepresentable {
  @Environment(\.presentationMode) var presentation
  @StateObject private var viewModel: ApplePayViewModel
  
  var onSuccess: (() -> Void)?
  
  public init(cardModel: CardModel, onSuccess: ( () -> Void)? = nil) {
    _viewModel = .init(wrappedValue: ApplePayViewModel(cardModel: cardModel))
    self.onSuccess = onSuccess
  }
  
  public func updateUIViewController(_: PKAddPaymentPassViewController, context _: Context) {}
  
  public func makeUIViewController(context: Context) -> PKAddPaymentPassViewController {
    let request = PKAddPaymentPassRequestConfiguration(encryptionScheme: .ECC_V2)
    request?.cardholderName = viewModel.cardModel.cardholderName
    request?.primaryAccountSuffix = viewModel.cardModel.last4
    request?.localizedDescription = LFLocalizable.AddToWallet.ApplePay.message
    request?.primaryAccountIdentifier = viewModel.cardModel.id
    request?.paymentNetwork = PKPaymentNetwork.visa
    if let request, let apm = PKAddPaymentPassViewController(requestConfiguration: request, delegate: context.coordinator) {
      return apm
    }
    return PKAddPaymentPassViewController()
  }
  
  public func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
}

extension ApplePayViewController {
  public class Coordinator: NSObject, PKAddPaymentPassViewControllerDelegate {
    var parent: ApplePayViewController
    
    init(_ parent: ApplePayViewController) {
      self.parent = parent
    }
    
    public func addPaymentPassViewController(_: PKAddPaymentPassViewController, generateRequestWithCertificateChain certificates: [Data], nonce: Data, nonceSignature: Data, completionHandler handler: @escaping (PKAddPaymentPassRequest) -> Void) {
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
              log.debug(cardData)
              let payloadData = cardData.encryptedCardData
              let activationcode = cardData.activationData
              let ephemeralkey = cardData.ephemeralPublicKey
              
              let encryptedPassData = Data(base64Encoded: payloadData ?? "", options: [])
              let ephemeralPublicKey = Data(base64Encoded: ephemeralkey ?? "", options: [])
              let activationData = Data(base64Encoded: activationcode ?? "", options: [])
              
              paymentPassRequest.activationData = activationData
              paymentPassRequest.encryptedPassData = encryptedPassData
              paymentPassRequest.ephemeralPublicKey = ephemeralPublicKey
              handler(paymentPassRequest)
            } else {
              handler(paymentPassRequest)
            }
          } catch {
            log.error(error.localizedDescription)
          }
        }
      }
    }
    
    public func addPaymentPassViewController(_: PKAddPaymentPassViewController, didFinishAdding _: PKPaymentPass?, error: Error?) {
      parent.presentation.wrappedValue.dismiss()
      if error == nil {
        parent.onSuccess?()
      }
    }
  }
}
