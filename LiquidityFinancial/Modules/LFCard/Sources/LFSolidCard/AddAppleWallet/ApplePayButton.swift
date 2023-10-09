import Foundation
import PassKit
import SwiftUI

struct ApplePayButton: UIViewRepresentable {
  class Coordinator: NSObject, PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewControllerDidFinish(_: PKPaymentAuthorizationViewController) {}
    
    func paymentAuthorizationViewController(
      _: PKPaymentAuthorizationViewController,
      didAuthorizePayment _: PKPayment,
      handler _: @escaping (PKPaymentAuthorizationResult) -> Void
    ) {}
    
    func paymentAuthorizationViewControllerWillAuthorizePayment(_: PKPaymentAuthorizationViewController) {}
  }
  
  func makeCoordinator() -> Coordinator {
    Coordinator()
  }
  
  func updateUIView(_: PKAddPassButton, context _: Context) {}
  
  func makeUIView(context _: Context) -> PKAddPassButton {
    let paymentButton = PKAddPassButton()
    paymentButton.addPassButtonStyle = .blackOutline
    return paymentButton
  }
}
