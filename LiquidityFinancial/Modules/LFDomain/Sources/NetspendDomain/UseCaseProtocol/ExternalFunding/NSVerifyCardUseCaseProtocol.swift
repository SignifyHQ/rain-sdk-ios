import Foundation

public protocol NSVerifyCardUseCaseProtocol {
  func execute(
    sessionId: String,
    request: VerifyExternalCardParametersEntity
  ) async throws -> VerifyExternalCardResponseEntity
}
