import Foundation
import RainDomain

public class RainCardRepository: RainCardRepositoryProtocol {
  private let rainCardAPI: RainCardAPIProtocol
  
  public init(rainCardAPI: RainCardAPIProtocol) {
    self.rainCardAPI = rainCardAPI
  }
  
  public func getCards() async throws -> [RainCardEntity] {
    try await rainCardAPI.getCards()
  }
  
  public func getCardOrders() async throws -> [RainCardEntity] {
    try await rainCardAPI.getCardOrders()
  }
  
  public func orderPhysicalCard(
    parameters: RainOrderCardParametersEntity,
    shouldBeApproved: Bool
  ) async throws -> RainCardEntity {
    guard let parameters = parameters as? APIRainOrderCardParameters
    else {
      throw "Can't map paramater :\(parameters)"
    }
    
    if shouldBeApproved {
      return try await rainCardAPI.orderPhysicalCardWithApproval(parameters: parameters)
    } else {
      return try await rainCardAPI.orderPhysicalCard(parameters: parameters)
    }
  }
  
  public func activatePhysicalCard(cardID: String, parameters: RainActivateCardParametersEntity) async throws {
    guard let parameters = parameters as? APIRainActivateCardParameters else {
      throw "Can't map paramater :\(parameters)"
    }
    return try await rainCardAPI.activatePhysicalCard(cardID: cardID, parameters: parameters)
  }
  
  public func closeCard(cardID: String) async throws -> RainCardEntity {
    try await rainCardAPI.closeCard(cardID: cardID)
  }
  
  public func lockCard(cardID: String) async throws -> RainCardEntity {
    try await rainCardAPI.lockCard(cardID: cardID)
  }
  
  public func unlockCard(cardID: String) async throws -> RainCardEntity {
    try await rainCardAPI.unlockCard(cardID: cardID)
  }
  
  public func cancelOrder(cardID: String) async throws -> RainCardEntity {
    try await rainCardAPI.cancelOrder(cardID: cardID)
  }
  
  public func getSecretCardInformation(sessionID: String, cardID: String) async throws -> RainSecretCardInformationEntity {
    try await rainCardAPI.getSecretCardInformation(sessionID: sessionID, cardID: cardID)
  }
  
  public func createVirtualCard() async throws -> RainCardEntity {
    try await rainCardAPI.createVirtualCard()
  }
}
