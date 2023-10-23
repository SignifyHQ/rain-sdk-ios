import Foundation
import NetSpendData
import Factory
import NetspendDomain

@MainActor
public protocol AddAppleWalletViewModelProtocol: ObservableObject {
  // Published Properties
  var isShowApplePay: Bool { get set }
  
  // Normal Properties
  var cardModel: CardModel { get }
  var onFinish: () -> Void { get }
  
  init(cardModel: CardModel, onFinish: @escaping () -> Void)
  
  // API
  func callEnrollWalletAPI(bodyData: [String: Any]) async throws -> PostApplePayTokenEntity?
  
  // View Helpers
  func onClickedAddToApplePay()
}
