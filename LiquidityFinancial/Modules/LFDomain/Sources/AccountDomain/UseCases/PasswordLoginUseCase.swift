import Foundation

public final class PasswordLoginUseCase: PasswordLoginUseCaseProtocol {
  
  private let repository: AccountRepositoryProtocol
  private let dataManager: AccountDataStorageProtocol
  
  public init(
    repository: AccountRepositoryProtocol,
    dataManager: AccountDataStorageProtocol
  ) {
    self.repository = repository
    self.dataManager = dataManager
  }
  
  public func execute(password: String) async throws -> PasswordLoginTokensEntity {
    let phoneNumber = dataManager.phoneNumber
    return try await repository.loginWithPassword(phoneNumner: phoneNumber, password: password)
  }
}
