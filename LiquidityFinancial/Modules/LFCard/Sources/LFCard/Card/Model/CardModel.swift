import Foundation
import LFLocalizable

public struct CardModel: Identifiable, Hashable {
  public let id: String
  public let cardType: CardType
  public let cardholderName: String?
  public  let currency: String?
  public let expiryMonth: String?
  public let expiryYear: String?
  public let last4: String?
  public var cardStatus: CardStatus?
  public var roundUpPurchases: Bool
  
  public static let virtualDefault = CardModel(
    id: "",
    cardType: .virtual,
    cardholderName: nil,
    currency: nil,
    expiryMonth: "09",
    expiryYear: "2023",
    last4: "1891",
    cardStatus: .active, // Default this card is activated
    roundUpPurchases: true
  )
  
  // TODO: Will be removed after intergrate with API
  public static let physicalDefault = CardModel(
    id: "12",
    cardType: .physical,
    cardholderName: "Fake name",
    currency: "222",
    expiryMonth: "2",
    expiryYear: "25",
    last4: "2222",
    cardStatus: .unactivated,
    roundUpPurchases: true
  )
}

public enum CardStatus: String {
  case active
  case closed
  case disabled
  case unactivated
}

public enum CardType {
  case virtual
  case physical
  
  public var title: String {
    switch self {
    case .virtual:
      return LFLocalizable.Card.Virtual.title
    case .physical:
      return LFLocalizable.Card.Physical.title
    }
  }
}
