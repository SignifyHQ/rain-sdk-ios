import Foundation
import Factory

@MainActor
public protocol AddAppleWalletViewModelProtocol: ObservableObject {
  // Published Properties
  var isShowApplePay: Bool { get set }
  
  // Normal Properties
  var cardModel: CardModel { get }
  var onFinish: () -> Void { get }
  
  init(cardModel: CardModel, onFinish: @escaping () -> Void)
  
  // API
  func callEnrollWalletAPI(bodyData: [String: Any]) async throws -> DigitalWalletLinkToken?
  
  // View Helpers
  func onClickedAddToApplePay()
}
