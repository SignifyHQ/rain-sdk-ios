import Foundation

// sourcery: AutoMockable
public protocol RainCardAPIProtocol {
  func getCards() async throws -> [APIRainCard]
  func orderPhysicalCard(parameters: APIRainOrderCardParameters) async throws -> APIRainCard
  func activatePhysicalCard(cardID: String, parameters: APIRainActivateCardParameters) async throws
}
