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
  
}
