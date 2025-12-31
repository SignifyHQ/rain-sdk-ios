import RainDomain
import LFUtilities
import Foundation

class CardDetail {
  let userId: String?
  let cardId: String?
  let rainPersonId: String?
  let rainCardId: String?
  let cardType: String?
  let cardStatus: String?
  let last4: String?
  let expMonth: String?
  let expYear: String?
  let limitAmount: Double?
  let limitFrequency: String?
  let createdAt: String?
  let tokenExperiences: [String]?
  let updatedAt: String?
  let shippingAddress: CardShippingDetail?
  
  init(entity: RainCardDetailEntity) {
    self.userId = entity.userId
    self.cardId = entity.cardId
    self.rainPersonId = entity.rainPersonId
    self.rainCardId = entity.rainCardId
    self.cardType = entity.cardType
    self.cardStatus = entity.cardStatus
    self.last4 = entity.last4
    self.expMonth = entity.expMonth
    self.expYear = entity.expYear
    self.limitAmount = entity.limitAmount
    self.limitFrequency = entity.limitFrequency
    self.createdAt = entity.createdAt
    self.tokenExperiences = entity.tokenExperiences
    self.updatedAt = entity.updatedAt
    self.shippingAddress = entity.shippingAddressEntity.map {
      CardShippingDetail(entity: $0)
    }
  }
}

extension CardDetail {
  func toCardModel() -> CardModel {
    CardModel(
      id: cardId ?? rainCardId ?? .empty,
      cardType: CardType(rawValue: cardType?.lowercased() ?? .empty) ?? .virtual,
      cardholderName: nil,
      expiryMonth: Int(expMonth ?? .empty) ?? 0,
      expiryYear: Int(expYear ?? .empty) ?? 0,
      last4: last4 ?? .empty,
      cardStatus: CardStatus(rawValue: cardStatus?.lowercased() ?? .empty) ?? .unactivated,
      tokenExperiences: tokenExperiences,
      shippingAddress: shippingAddress?.toShippingAddress(),
      updatedAt: updatedAt
    )
  }
}
