import Foundation

// sourcery: AutoMockable
public protocol RainCardAPIProtocol {
  func getCards() async throws -> [APIRainCard]
}
