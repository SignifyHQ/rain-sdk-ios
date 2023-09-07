import Foundation
import LFUtilities

public final class AccountUseCase: AccountUseCaseProtocol {
  
  private let repository: AccountRepositoryProtocol
  
  public init(repository: AccountRepositoryProtocol) {
    self.repository = repository
  }
  
  public func execute(
    accountId: String, currencyType: String, transactionTypes: String, limit: Int, offset: Int
  ) async throws -> TransactionListEntity {
    try await repository.getTransactions(
      accountId: accountId, currencyType: currencyType, transactionTypes: transactionTypes, limit: limit, offset: offset
    )
  }
  
  public func logout() async throws -> Bool {
    return try await repository.logout()
  }
  
  public func getReferralCampaign() async throws -> ReferralCampaignEntity {
    return try await repository.getReferralCampaign()
  }
  
  public func getTaxFile(accountId: String) async throws -> [any TaxFileEntity] {
    return try await repository.getTaxFile(accountId: accountId)
  }
  
  public func getTaxFileYear(accountId: String, year: String, fileName: String) async throws -> URL {
    return try await repository.getTaxFileYear(accountId: accountId, year: year, fileName: fileName)
  }
  
  public func addToWaitList(waitList: String) async throws -> Bool {
    return try await repository.addToWaitList(waitList: waitList)
  }
  
  public func getUserRewards() async throws -> [UserRewardsEntity] {
    return try await repository.getUserRewards()
  }
  
  public func getFeatureConfig() async throws -> AccountFeatureConfigEntity {
    return try await repository.getFeatureConfig()
  }
}
