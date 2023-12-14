import Foundation

public protocol ResetPasswordVerifyUseCaseProtocol {
  func execute(code: String) async throws -> PasswordResetTokenEntity
}
