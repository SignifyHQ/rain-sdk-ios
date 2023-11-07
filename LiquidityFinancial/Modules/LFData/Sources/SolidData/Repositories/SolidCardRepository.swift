import SolidDomain

public class SolidCardRepository: SolidCardRepositoryProtocol {
  private let cardAPI: SolidCardAPIProtocol
  
  public init(cardAPI: SolidCardAPIProtocol) {
    self.cardAPI = cardAPI
  }
  
  public func getListCard() async throws -> [SolidCardEntity] {
    try await cardAPI.getListCard()
  }
  
  public func updateCardStatus(cardID: String, parameters: SolidCardStatusParametersEntity) async throws -> SolidCardEntity {
    guard let parameters = parameters as? APISolidCardStatusParameters else {
      throw "Can't map paramater :\(parameters)"
    }
    return try await cardAPI.updateCardStatus(cardID: cardID, parameters: parameters)
  }
  
  public func closeCard(cardID: String) async throws -> Bool {
    try await cardAPI.closeCard(cardID: cardID)
  }
  
  public func createVGSShowToken(cardID: String) async throws -> SolidCardShowTokenEntity {
   try await cardAPI.createVGSShowToken(cardID: cardID)
  }
  
  public func createDigitalWalletLink(
    cardID: String,
    parameters: SolidApplePayParametersEntity
  ) async throws -> SolidDigitalWalletEntity {
    guard let parameters = parameters as? APISolidApplePayWalletParameters else {
      throw "Can't map paramater :\(parameters)"
    }
    return try await cardAPI.createDigitalWalletLink(cardID: cardID, parameters: parameters)
  }
  
}
