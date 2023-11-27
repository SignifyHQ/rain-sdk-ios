import Foundation

public protocol NSUnLockCardUseCaseProtocol {
  func execute(cardID: String, sessionID: String) async throws -> NSCardEntity
}
