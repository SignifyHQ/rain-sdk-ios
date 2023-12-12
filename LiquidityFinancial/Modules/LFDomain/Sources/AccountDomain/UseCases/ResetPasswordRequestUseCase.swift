import Foundation

public final class ResetPasswordRequestUseCase: ResetPasswordRequestUseCaseProtocol {
  
  private let repository: AccountRepositoryProtocol
  private let dataManager: AccountDataStorageProtocol
  
  public init(
    repository: AccountRepositoryProtocol,
    dataManager: AccountDataStorageProtocol
  ) {
    self.repository = repository
    self.dataManager = dataManager
  }
  
  public func execute() async throws {
    let phoneNumber = dataManager.phoneNumber
    return try await repository.resetPasswordRequest(phoneNumber: phoneNumber)
  }
}
