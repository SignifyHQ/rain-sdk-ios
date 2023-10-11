import Foundation

protocol AccountUseCaseProtocol {
  func execute(
    accountId: String, currencyType: String, transactionTypes: String, limit: Int, offset: Int
  ) async throws -> TransactionListEntity
  func logout() async throws -> Bool
  
  func getReferralCampaign() async throws -> ReferralCampaignEntity
  func getTaxFile(accountId: String) async throws -> [any TaxFileEntity]
  func getTaxFileYear(accountId: String, year: String, fileName: String) async throws -> URL
  func addToWaitList(waitList: String) async throws -> Bool
  func getUserRewards() async throws -> [UserRewardsEntity]
  func getFeatureConfig() async throws -> AccountFeatureConfigEntity
}
