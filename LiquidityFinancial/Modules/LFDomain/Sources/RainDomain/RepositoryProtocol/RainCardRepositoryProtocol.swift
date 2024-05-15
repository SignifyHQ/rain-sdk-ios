import Foundation

// sourcery: AutoMockable
public protocol RainCardRepositoryProtocol {
  func getCards() async throws -> [RainCardEntity]
  func orderPhysicalCard(parameters: RainOrderCardParametersEntity) async throws -> RainCardEntity
  func activatePhysicalCard(cardID: String, parameters: RainActivateCardParametersEntity) async throws
}
