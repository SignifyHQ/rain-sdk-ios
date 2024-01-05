import Foundation

public final class ResetPasswordUseCase: ResetPasswordUseCaseProtocol {
  
  private let repository: AccountRepositoryProtocol
  
  public init(repository: AccountRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(phoneNumber: String, password: String, token: String) async throws {
    try await repository.resetPassword(phoneNumber: phoneNumber, password: password, token: token)
  }
}
