import Foundation
import BaseOnboarding
import RainDomain

struct CardModel: Identifiable, Hashable {
  let id: String
  let cardType: CardType
  let cardholderName: String?
  let expiryMonth: Int
  let expiryYear: Int
  let last4: String
  var cardStatus: CardStatus
  var metadata: CardMetaData?
  var tokenExperiences: [String]?
  var shippingAddress: ShippingAddress?
  
  var expiryTime: String {
    let expiryMonthFormated = expiryMonth < 10 ? "0\(expiryMonth)" : "\(expiryMonth)"
    let expiryYearFormated = "\(expiryYear)".suffix(2)
    return "\(expiryMonthFormated)/\(expiryYearFormated)"
  }
  
  init(
    id: String,
    cardType: CardType,
    cardholderName: String? = nil,
    expiryMonth: Int = 0,
    expiryYear: Int = 0,
    last4: String = .empty,
    cardStatus: CardStatus,
    tokenExperiences: [String]? = nil,
    shippingAddress: ShippingAddress? = nil
  ) {
    self.id = id
    self.cardType = cardType
    self.cardholderName = cardholderName
    self.expiryMonth = expiryMonth
    self.expiryYear = expiryYear
    self.last4 = last4
    self.cardStatus = cardStatus
    self.tokenExperiences = tokenExperiences
    self.shippingAddress = shippingAddress
  }
  
  init(
    card: RainCardEntity
  ) {
    id = card.cardId ?? card.rainCardId
    cardType = CardType(rawValue: card.cardType.lowercased()) ?? .virtual
    cardholderName = nil
    expiryMonth = Int(card.expMonth ?? .empty) ?? 0
    expiryYear = Int(card.expYear ?? .empty) ?? 0
    last4 = card.last4 ?? .empty
    cardStatus = CardStatus(rawValue: card.cardStatus.lowercased()) ?? .unactivated
    tokenExperiences = card.tokenExperiences
  }
  
  init(
    order: RainCardOrderEntity
  ) {
    id = order.id
    cardType = .physical
    cardStatus = CardStatus(rawValue: order.status.lowercased()) ?? .pending
    shippingAddress = ShippingAddress(
      line1: order.line1,
      line2: order.line2,
      city: order.city,
      state: order.city,
      postalCode: order.postalCode,
      country: Country(rawValue: order.countryCode) ?? .US
    )
    
    cardholderName = nil
    expiryMonth = 0
    expiryYear = 0
    last4 = .empty
  }
  
  static let virtualDefault = CardModel(
    id: "",
    cardType: .virtual,
    cardholderName: nil,
    expiryMonth: 9,
    expiryYear: 2_023,
    last4: "1891",
    cardStatus: .active
  )
  
  static let physicalDefault = CardModel(
    id: "",
    cardType: .physical,
    cardStatus: .unactivated
  )
}
