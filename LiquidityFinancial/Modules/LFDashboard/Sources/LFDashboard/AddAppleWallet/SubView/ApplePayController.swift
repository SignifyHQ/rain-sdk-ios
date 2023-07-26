import Foundation
import PassKit
import SwiftUI
import LFLocalizable

struct ApplePayController: UIViewControllerRepresentable {
  @Environment(\.presentationMode) var presentation
  var cardModel: CardModel
  var onSuccess: (() -> Void)?
  
  func updateUIViewController(_: PKAddPaymentPassViewController, context _: Context) {}
  
  func makeUIViewController(context: Context) -> PKAddPaymentPassViewController {
    // TODO: Will be implemented later
    // analyticsService.track(event: Event(name: .viewsAddApplePay))
    let request = PKAddPaymentPassRequestConfiguration(encryptionScheme: .ECC_V2)
    request?.cardholderName = cardModel.cardholderName
    request?.primaryAccountSuffix = cardModel.last4
    request?.localizedDescription = LFLocalizable.AddToWallet.ApplePay.message
    request?.primaryAccountIdentifier = cardModel.id
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

extension ApplePayController {
  class Coordinator: NSObject, PKAddPaymentPassViewControllerDelegate {
    var parent: ApplePayController
    
    init(_ parent: ApplePayController) {
      self.parent = parent
    }
    
    func addPaymentPassViewController(_: PKAddPaymentPassViewController, generateRequestWithCertificateChain certificates: [Data], nonce: Data, nonceSignature: Data, completionHandler handler: @escaping (PKAddPaymentPassRequest) -> Void) {
      // TODO: Will be implemented later
      // analyticsService.track(event: Event(name: .tapsAddApplePay))
      //      let certificateLeaf = certificates[0].base64EncodedString()
      //      let nonceString = nonce.base64EncodedString()
      //      let nonceSignatureVal = nonceSignature.base64EncodedString()
      //      let paymentPassRequest = PKAddPaymentPassRequest()
      //      let aPay = Applepay(deviceCert: certificateLeaf, nonceSignature: nonceSignatureVal, nonce: nonceString)
      //      let postBody = CardWalletRequestBody(wallet: "applePay", applePay: aPay)
      //
      //      if !parent.cardModel.id.isEmpty {
      //        CardViewModel().callEnrollWalletAPI(cardID: parent.cardModel.id, param: postBody) { response, status, _ in
      //          if status == true {
      //            if let cardData = response {
      //              let payloadData = cardData.applePay?.encryptedPassData
      //              let activationcode = cardData.applePay?.activationData
      //              let ephemeralkey = cardData.applePay?.ephemeralPublicKey
      //
      //              let encryptedPassData = Data(base64Encoded: payloadData ?? "", options: [])
      //              let ephemeralPublicKey = Data(base64Encoded: ephemeralkey ?? "", options: [])
      //              let activationData = Data(base64Encoded: activationcode ?? "", options: [])
      //
      //              paymentPassRequest.activationData = activationData
      //              paymentPassRequest.encryptedPassData = encryptedPassData
      //              paymentPassRequest.ephemeralPublicKey = ephemeralPublicKey
      //              handler(paymentPassRequest)
      //            }
      //          }
      //        }
      //      }
    }
    
    func addPaymentPassViewController(_: PKAddPaymentPassViewController, didFinishAdding _: PKPaymentPass?, error: Error?) {
      // TODO: Will be implemented later
      //      let eventName: EventName = error == nil ? .applePayConnectSuccess : .applePayConnectError
      //      analyticsService.track(event: Event(name: eventName))
      parent.presentation.wrappedValue.dismiss()
      if error == nil {
        parent.onSuccess?()
      }
    }
  }
}
