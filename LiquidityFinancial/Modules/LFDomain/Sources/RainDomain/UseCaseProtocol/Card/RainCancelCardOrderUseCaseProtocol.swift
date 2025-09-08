import Foundation

public protocol RainCancelCardOrderUseCaseProtocol {
  func execute(cardID: String) async throws -> RainCardOrderEntity
}
