import Foundation

public protocol NSVerifyCVVCodeUseCaseProtocol {
  func execute(
    requestParam: VerifyCVVCodeParametersEntity,
    cardID: String,
    sessionID: String
  ) async throws -> VerifyCVVCodeEntity
}
