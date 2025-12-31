import Foundation

public protocol RainGetCardDetailUseCaseProtocol {
  func execute(cardID: String) async throws -> RainCardDetailEntity
}
