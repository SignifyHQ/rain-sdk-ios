import Foundation

public protocol RainCloseCardUseCaseProtocol {
  func execute(cardID: String) async throws -> RainCardEntity
}
