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
}
