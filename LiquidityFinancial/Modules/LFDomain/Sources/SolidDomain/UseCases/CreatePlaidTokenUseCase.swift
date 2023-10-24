import Foundation

public class CreatePlaidTokenUseCase: CreatePlaidTokenUseCaseProtocol {
  
  private let repository: SolidExternalFundingRepositoryProtocol
  
  public init(repository: SolidExternalFundingRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(accountId: String) async throws -> CreatePlaidTokenResponseEntity {
    try await repository.createPlaidToken(accountID: accountId)
  }
  
}
