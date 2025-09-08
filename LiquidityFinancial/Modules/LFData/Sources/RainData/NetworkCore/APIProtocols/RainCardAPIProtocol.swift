import Foundation

// sourcery: AutoMockable
public protocol RainCardAPIProtocol {
  func getCards() async throws -> [APIRainCard]
  func getCardOrders() async throws -> [APIRainCardOrder]
  func orderPhysicalCard(parameters: APIRainOrderCardParameters) async throws -> APIRainCard
  func orderPhysicalCardWithApproval(parameters: APIRainOrderCardParameters) async throws -> APIRainCardOrder
  func activatePhysicalCard(cardID: String, parameters: APIRainActivateCardParameters) async throws
  func closeCard(cardID: String) async throws -> APIRainCard
  func lockCard(cardID: String) async throws -> APIRainCard
  func unlockCard(cardID: String) async throws -> APIRainCard
  func cancelOrder(cardID: String) async throws -> APIRainCardOrder
  func getSecretCardInformation(sessionID: String, cardID: String) async throws -> APIRainSecretCardInformation
  func createVirtualCard() async throws -> APIRainCard
}
