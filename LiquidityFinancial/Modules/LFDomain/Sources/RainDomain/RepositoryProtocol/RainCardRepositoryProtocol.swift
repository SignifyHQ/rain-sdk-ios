import Foundation

// sourcery: AutoMockable
public protocol RainCardRepositoryProtocol {
  func getCards() async throws -> [RainCardEntity]
  func getCardDetail(cardID: String) async throws -> RainCardDetailEntity
  func getCardOrders() async throws -> [RainCardOrderEntity]
  func orderPhysicalCard(parameters: RainOrderCardParametersEntity) async throws -> RainCardEntity
  func orderPhysicalCardWithApproval(parameters: RainOrderCardParametersEntity) async throws -> RainCardOrderEntity
  func activatePhysicalCard(cardID: String, parameters: RainActivateCardParametersEntity) async throws
  func closeCard(cardID: String) async throws -> RainCardEntity
  func lockCard(cardID: String) async throws -> RainCardEntity
  func unlockCard(cardID: String) async throws -> RainCardEntity
  func cancelOrder(cardID: String) async throws -> RainCardOrderEntity
  func getSecretCardInformation(sessionID: String, cardID: String) async throws -> RainSecretCardInformationEntity
  func createVirtualCard() async throws -> RainCardEntity
  func getPending3dsChallenges() async throws -> [Pending3dsChallengeEntity]
  func make3dsChallengeDecision(approvalId: String, decision: String) async throws
}
