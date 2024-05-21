import Foundation

// sourcery: AutoMockable
public protocol RainCardAPIProtocol {
  func getCards() async throws -> [APIRainCard]
  func orderPhysicalCard(parameters: APIRainOrderCardParameters) async throws -> APIRainCard
  func activatePhysicalCard(cardID: String, parameters: APIRainActivateCardParameters) async throws
  func closeCard(cardID: String) async throws -> APIRainCard
  func lockCard(cardID: String) async throws -> APIRainCard
  func unlockCard(cardID: String) async throws -> APIRainCard
  func getSecretCardInformation(sessionID: String, cardID: String) async throws -> APIRainSecretCardInformation
  func createVirtualCard() async throws -> APIRainCard
}
