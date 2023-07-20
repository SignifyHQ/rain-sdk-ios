import Foundation

struct CardModel: Identifiable {
  let id: String
  let cardholderName: String?
  let currency: String?
  let expiryMonth: String?
  let expiryYear: String?
  let last4: String?
  var cardStatus: CardStatus?
  var roundUpPurchases: Bool
  
  static let `default` = CardModel(
    id: "",
    cardholderName: nil,
    currency: nil,
    expiryMonth: "09",
    expiryYear: "2023",
    last4: "1891",
    cardStatus: .pendingActivation,
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
