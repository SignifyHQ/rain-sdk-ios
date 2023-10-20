import Foundation

public class CreatePlaidTokenUseCase: CreatePlaidTokenUseCaseProtocol {
  
  private let repository: LinkSourceRepositoryProtocol
  
  public init(repository: LinkSourceRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(accountId: String) async throws -> CreatePlaidTokenResponseEntity {
    try await repository.createPlaidToken(accountID: accountId)
  }
  
}
