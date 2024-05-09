import Foundation

// sourcery: AutoMockable
public protocol RainCardRepositoryProtocol {
  func getCards() async throws -> [RainCardEntity]
}
