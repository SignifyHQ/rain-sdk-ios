import Foundation

public protocol RainLockCardUseCaseProtocol {
  func execute(cardID: String) async throws -> RainCardEntity
}
