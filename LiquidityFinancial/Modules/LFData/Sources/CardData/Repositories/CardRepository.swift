import Foundation
import CardDomain

public class CardRepository: CardRepositoryProtocol {
  private let cardAPI: CardAPIProtocol
  
  public init(cardAPI: CardAPIProtocol) {
    self.cardAPI = cardAPI
  }
  
  public func getListCard() async throws -> [CardEntity] {
    try await cardAPI.getListCard()
  }
  
  public func lockCard(cardID: String, sessionID: String) async throws -> CardEntity {
    try await cardAPI.lockCard(cardID: cardID, sessionID: sessionID)
  }
  
  public func unlockCard(cardID: String, sessionID: String) async throws -> CardEntity {
    try await cardAPI.unlockCard(cardID: cardID, sessionID: sessionID)
  }
}

extension APICard: CardEntity {
  public var shippingAddressEntity: CardDomain.ShippingAddressEntity? {
    shippingAddress
  }
}
