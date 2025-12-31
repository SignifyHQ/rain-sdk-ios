import Foundation
import RainDomain

public struct APIRainCardDetail: Decodable, RainCardDetailEntity {
  public let userId: String?
  public let cardId: String?
  public let rainPersonId: String?
  public let rainCardId: String?
  public let cardType: String?
  public let cardStatus: String?
  public let last4: String?
  public let expMonth: String?
  public let expYear: String?
  public let limitAmount: Double?
  public let limitFrequency: String?
  public let createdAt: String?
  public let tokenExperiences: [String]?
  public let updatedAt: String?
  public let shippingAddress: APIRainCardShippingAddress?
  
  public var shippingAddressEntity: RainCardShippingAddressEntity? {
    shippingAddress
  }
}
