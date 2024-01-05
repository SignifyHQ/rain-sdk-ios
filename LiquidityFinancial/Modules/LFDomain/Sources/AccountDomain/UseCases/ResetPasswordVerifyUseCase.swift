import Foundation

public final class ResetPasswordVerifyUseCase: ResetPasswordVerifyUseCaseProtocol {
  
  private let repository: AccountRepositoryProtocol
  
  public init(repository: AccountRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(phoneNumber: String, code: String) async throws -> PasswordResetTokenEntity {
    try await repository.resetPasswordVerify(phoneNumber: phoneNumber, code: code)
  }
}
