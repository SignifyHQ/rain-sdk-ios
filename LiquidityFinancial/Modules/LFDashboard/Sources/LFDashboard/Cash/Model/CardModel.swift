import Foundation
import LFLocalizable

struct CardModel: Identifiable, Hashable {
  let id: String
  let cardType: CardType
  let cardholderName: String?
  let currency: String?
  let expiryMonth: String?
  let expiryYear: String?
  let last4: String?
  var cardStatus: CardStatus?
  var roundUpPurchases: Bool
  
  static let `default` = CardModel(
    id: "",
    cardType: .virtual,
    cardholderName: nil,
    currency: nil,
    expiryMonth: "09",
    expiryYear: "2023",
    last4: "1891",
    cardStatus: .active,
    roundUpPurchases: true
  )
}

enum CardStatus: String {
  case pendingActivation
  case active
  case inactive
  case canceled
  case unknown
}

enum CardType {
  case virtual
  case physical
  
  var title: String {
    switch self {
    case .virtual:
      return LFLocalizable.Card.Virtual.title
    case .physical:
      return LFLocalizable.Card.Physical.title
    }
  }
}
