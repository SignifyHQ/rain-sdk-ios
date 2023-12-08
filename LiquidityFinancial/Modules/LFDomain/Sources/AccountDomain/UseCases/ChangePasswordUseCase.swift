import Foundation

public final class ChangePasswordUseCase: ChangePasswordUseCaseProtocol {
  
  private let repository: AccountRepositoryProtocol
  
  public init(repository: AccountRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(oldPassword: String, newPassword: String) async throws {
    try await repository.changePassword(
      oldPassword: oldPassword, newPassword: newPassword
    )
  }
}
