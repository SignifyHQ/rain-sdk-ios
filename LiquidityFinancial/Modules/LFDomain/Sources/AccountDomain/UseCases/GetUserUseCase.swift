import Foundation

public final class GetUserUseCase: GetUserUseCaseProtocol {
  
  private let repository: AccountRepositoryProtocol
  private let dataManager: AccountDataStorageProtocol
  
  public init(
    repository: AccountRepositoryProtocol,
    dataManager: AccountDataStorageProtocol
  ) {
    self.repository = repository
    self.dataManager = dataManager
  }

  public func execute() async throws -> LFUser {
    let user = try await repository.getUser()
    dataManager.storeUser(user: user)
    
    return user
  }
}
