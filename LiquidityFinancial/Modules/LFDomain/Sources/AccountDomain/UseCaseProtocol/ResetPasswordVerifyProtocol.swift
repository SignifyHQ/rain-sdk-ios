import Foundation

public protocol ResetPasswordVerifyUseCaseProtocol {
  func execute(phoneNumber: String, code: String) async throws -> PasswordResetTokenEntity
}
