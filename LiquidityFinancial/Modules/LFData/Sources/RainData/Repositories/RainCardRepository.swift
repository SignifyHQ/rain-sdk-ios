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
  
  public func orderPhysicalCard(parameters: RainOrderCardParametersEntity) async throws -> RainCardEntity {
    guard let parameters = parameters as? APIRainOrderCardParameters else {
      throw "Can't map paramater :\(parameters)"
    }
    return try await rainCardAPI.orderPhysicalCard(parameters: parameters)
  }
}
