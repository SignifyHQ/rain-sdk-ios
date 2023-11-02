import SolidDomain

public class SolidCardRepository: SolidCardRepositoryProtocol {
  private let cardAPI: SolidCardAPIProtocol
  
  public init(cardAPI: SolidCardAPIProtocol) {
    self.cardAPI = cardAPI
  }
  
  public func getListCard() async throws -> [SolidCardEntity] {
    return try await cardAPI.getListCard()
  }
}
