import Foundation

// sourcery: AutoMockable
public protocol RainCardRepositoryProtocol {
  func getCards() async throws -> [RainCardEntity]
  func orderPhysicalCard(parameters: RainOrderCardParametersEntity) async throws -> RainCardEntity
}
