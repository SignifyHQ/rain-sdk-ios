import Foundation
import OnboardingData
import CardDomain
import CommonDomain
import NetspendSdk

public class CardRepository: CardRepositoryProtocol {
  private let cardAPI: CardAPIProtocol
  
  public init(cardAPI: CardAPIProtocol) {
    self.cardAPI = cardAPI
  }
  
  public func getListCard() async throws -> [CardEntity] {
    try await cardAPI.getListCard()
  }
  
  public func getCard(cardID: String, sessionID: String) async throws -> CardEntity {
    try await cardAPI.getCard(cardID: cardID, sessionID: sessionID)
  }
  
  public func lockCard(cardID: String, sessionID: String) async throws -> CardEntity {
    try await cardAPI.lockCard(cardID: cardID, sessionID: sessionID)
  }
  
  public func unlockCard(cardID: String, sessionID: String) async throws -> CardEntity {
    try await cardAPI.unlockCard(cardID: cardID, sessionID: sessionID)
  }
  
  public func orderPhysicalCard(address: AddressEntity, sessionID: String) async throws -> CardEntity {
    let address = APIAddress(entity: address)
    return try await cardAPI.orderPhysicalCard(address: address, sessionID: sessionID)
  }
}

extension APICard: CardEntity {
  public func decodeData<T: CardEncryptedEntity>(session: NetspendSdkUserSession) -> T? {
    APICard.decodeData(session: session, encryptedData: encryptedData) as? T
  }
  
  public var shippingAddressEntity: CardDomain.ShippingAddressEntity? {
    shippingAddress
  }
}
