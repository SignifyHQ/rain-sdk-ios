import Foundation

public protocol NSCreateCardUseCaseProtocol {
  func execute(sessionID: String) async throws -> NSCardEntity
}
