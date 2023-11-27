import Foundation

public protocol NSSetCardPinUseCaseProtocol {
  func execute(
    requestParam: SetPinRequestEntity,
    cardID: String,
    sessionID: String
  ) async throws -> NSCardEntity
}
