import Foundation

public final class ResetPasswordRequestUseCase: ResetPasswordRequestUseCaseProtocol {
  
  private let repository: AccountRepositoryProtocol
  
  public init(repository: AccountRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(phoneNumber: String) async throws {
    try await repository.resetPasswordRequest(phoneNumber: phoneNumber)
  }
}
