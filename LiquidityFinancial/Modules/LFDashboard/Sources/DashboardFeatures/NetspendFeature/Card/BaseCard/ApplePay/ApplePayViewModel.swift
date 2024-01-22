import Foundation
import Factory

@MainActor
public protocol ApplePayViewModelProtocol: ObservableObject {
  var cardModel: CardModel { get }
  
  init(cardModel: CardModel)
  
  // API Functions
  func callEnrollWalletAPI(bodyData: [String: Any]) async throws -> DigitalWalletLinkToken?
}
