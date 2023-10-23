import Foundation
import NetSpendData
import Factory

@MainActor
public protocol CardViewModelProtocol: ObservableObject {
  // Published Properties
  var isCardAvailable: Bool { get set }
  var isShowCardCopyMessage: Bool { get set }
  var cardNumber: String { get set }
  var expirationTime: String { get set }
  var cvvNumber: String { get set }
  var cardModel: CardModel { get set }
  
  init(cardModel: CardModel)
  
  // View Helpers
  func copyAction(cardNumber: String?)
  func hideCardInformation()
}
