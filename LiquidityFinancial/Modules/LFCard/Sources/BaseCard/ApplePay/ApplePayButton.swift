import Foundation
import PassKit
import SwiftUI

public struct ApplePayButton: UIViewRepresentable {
  public init() {}
  
  public class Coordinator: NSObject, PKPaymentAuthorizationViewControllerDelegate {
    public func paymentAuthorizationViewControllerDidFinish(_: PKPaymentAuthorizationViewController) {}
    
    public func paymentAuthorizationViewController(
      _: PKPaymentAuthorizationViewController,
      didAuthorizePayment _: PKPayment,
      handler _: @escaping (PKPaymentAuthorizationResult) -> Void
    ) {}
    
    public func paymentAuthorizationViewControllerWillAuthorizePayment(_: PKPaymentAuthorizationViewController) {}
  }
  
  public func makeCoordinator() -> Coordinator {
    Coordinator()
  }
  
  public func updateUIView(_: PKAddPassButton, context _: Context) {}
  
  public func makeUIView(context _: Context) -> PKAddPassButton {
    let paymentButton = PKAddPassButton()
    paymentButton.addPassButtonStyle = .blackOutline
    return paymentButton
  }
}
