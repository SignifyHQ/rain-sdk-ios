import Foundation

public class SolidDebitCardTokenUseCase: SolidDebitCardTokenUseCaseProtocol {

  private let repository: SolidExternalFundingRepositoryProtocol
  
  public init(repository: SolidExternalFundingRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(accountID: String) async throws -> SolidDebitCardTokenEntity {
    try await repository.createDebitCardToken(accountID: accountID)
  }
  
}
