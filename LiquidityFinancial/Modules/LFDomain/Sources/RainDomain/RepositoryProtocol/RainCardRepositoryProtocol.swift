import Foundation

// sourcery: AutoMockable
public protocol RainCardRepositoryProtocol {
  func getCards() async throws -> [RainCardEntity]
  func getCardOrders() async throws -> [RainCardEntity]
  func orderPhysicalCard(parameters: RainOrderCardParametersEntity, shouldBeApproved: Bool) async throws -> RainCardEntity
  func activatePhysicalCard(cardID: String, parameters: RainActivateCardParametersEntity) async throws
  func closeCard(cardID: String) async throws -> RainCardEntity
  func lockCard(cardID: String) async throws -> RainCardEntity
  func unlockCard(cardID: String) async throws -> RainCardEntity
  func cancelOrder(cardID: String) async throws -> RainCardEntity
  func getSecretCardInformation(sessionID: String, cardID: String) async throws -> RainSecretCardInformationEntity
  func createVirtualCard() async throws -> RainCardEntity
}
