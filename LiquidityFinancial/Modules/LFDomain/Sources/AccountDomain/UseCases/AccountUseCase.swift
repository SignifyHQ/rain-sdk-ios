import Foundation
import LFUtilities

public final class AccountUseCase: AccountUseCaseProtocol {
  
  private let repository: AccountRepositoryProtocol
  
  public init(repository: AccountRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(accountId: String, currencyType: String, limit: Int, offset: Int) async throws -> [TransactionEntity] {
    return try await repository.getTransactions(accountId: accountId, currencyType: currencyType, limit: limit, offset: offset)
  }
}
