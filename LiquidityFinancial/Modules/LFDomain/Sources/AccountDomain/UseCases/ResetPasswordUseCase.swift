import Foundation

public final class ResetPasswordUseCase: ResetPasswordUseCaseProtocol {
  
  private let repository: AccountRepositoryProtocol
  private let dataManager: AccountDataStorageProtocol
  
  public init(
    repository: AccountRepositoryProtocol,
    dataManager: AccountDataStorageProtocol
  ) {
    self.repository = repository
    self.dataManager = dataManager
  }
  
  public func execute(password: String, token: String) async throws {
    let phoneNumber = dataManager.phoneNumber
    return try await repository.resetPassword(phoneNumber: phoneNumber, password: password, token: token)
  }
}
