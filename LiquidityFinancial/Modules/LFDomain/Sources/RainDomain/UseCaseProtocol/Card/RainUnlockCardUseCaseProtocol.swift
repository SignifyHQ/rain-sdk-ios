import Foundation

public protocol RainUnlockCardUseCaseProtocol {
  func execute(cardID: String) async throws -> RainCardEntity
}
