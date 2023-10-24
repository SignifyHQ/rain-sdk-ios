import Foundation

public class PlaidLinkUseCase: PlaidLinkUseCaseProtocol {
  
  private let repository: SolidExternalFundingRepositoryProtocol
  
  public init(repository: SolidExternalFundingRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(accountId: String, token: String, plaidAccountId: String) async throws -> any SolidContactEntity {
    return try await repository.linkPlaid(accountId: accountId, token: token, plaidAccountId: plaidAccountId)
  }
}
