import Foundation

public final class ResetPasswordVerifyUseCase: ResetPasswordVerifyUseCaseProtocol {
  
  private let repository: AccountRepositoryProtocol
  private let dataManager: AccountDataStorageProtocol
  
  public init(
    repository: AccountRepositoryProtocol,
    dataManager: AccountDataStorageProtocol
  ) {
    self.repository = repository
    self.dataManager = dataManager
  }
  
  public func execute(code: String) async throws {
    let phoneNumber = dataManager.phoneNumber
    return try await repository.resetPasswordVerify(phoneNumber: phoneNumber, code: code)
  }
}
