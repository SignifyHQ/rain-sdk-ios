import Foundation

public protocol NSCloseCardUseCaseProtocol {
  func execute(
    reason: CloseCardReasonEntity,
    cardID: String,
    sessionID: String
  ) async throws -> NSCardEntity
}
