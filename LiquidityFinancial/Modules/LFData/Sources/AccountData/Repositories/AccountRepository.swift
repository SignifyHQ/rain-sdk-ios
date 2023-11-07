import Foundation
import AuthorizationManager
import AccountDomain
import LFUtilities

public class AccountRepository: AccountRepositoryProtocol {
  
  private let accountAPI: AccountAPIProtocol
  private let auth: AuthorizationManagerProtocol
  
  public init(accountAPI: AccountAPIProtocol, auth: AuthorizationManagerProtocol) {
    self.accountAPI = accountAPI
    self.auth = auth
  }
  
  public func createZeroHashAccount() async throws -> ZeroHashAccount {
    return try await accountAPI.createZeroHashAccount()
  }
  
  public func getUser() async throws -> LFUser {
    return try await accountAPI.getUser()
  }
  
  public func getAvailableRewardCurrrencies() async throws -> AvailableRewardCurrenciesEntity {
    try await accountAPI.getAvailableRewardCurrencies()
  }
  
  public func getSelectedRewardCurrency() async throws -> RewardCurrencyEntity {
    try await accountAPI.getSelectedRewardCurrency()
  }
  
  public func updateSelectedRewardCurrency(rewardCurrency: String) async throws -> RewardCurrencyEntity {
    try await accountAPI.updateSelectedRewardCurrency(rewardCurrency: rewardCurrency)
  }
  
  public func getTransactions(
    accountId: String, currencyType: String, transactionTypes: String, limit: Int, offset: Int
  ) async throws -> TransactionListEntity {
    try await accountAPI.getTransactions(
      accountId: accountId, currencyType: currencyType, transactionTypes: transactionTypes, limit: limit, offset: offset
    )
  }
  
  public func getTransactionDetail(accountId: String, transactionId: String) async throws -> TransactionEntity {
    return try await accountAPI.getTransactionDetail(accountId: accountId, transactionId: transactionId)
  }
  
  public func logout() async throws -> Bool {
    return try await accountAPI.logout()
  }
  
  public func createWalletAddresses(accountId: String, address: String, nickname: String) async throws -> WalletAddressEntity {
    try await accountAPI.createWalletAddresses(accountId: accountId, address: address, nickname: nickname)
  }
  
  public func updateWalletAddresses(accountId: String, walletId: String, walletAddress: String, nickname: String) async throws -> WalletAddressEntity {
    try await accountAPI.updateWalletAddresses(
      accountId: accountId,
      walletId: walletId,
      walletAddress: walletAddress,
      nickname: nickname
    )
  }
  
  public func getWalletAddresses(accountId: String) async throws -> [WalletAddressEntity] {
    try await accountAPI.getWalletAddresses(accountId: accountId)
  }
  
  public func deleteWalletAddresses(accountId: String, walletAddress: String) async throws -> DeleteWalletEntity {
    try await accountAPI.deleteWalletAddresses(accountId: accountId, walletAddress: walletAddress)
  }
  
  public func getReferralCampaign() async throws -> ReferralCampaignEntity {
    try await accountAPI.getReferralCampaign()
  }
  
  public func getTaxFile(accountId: String) async throws -> [any TaxFileEntity] {
    try await accountAPI.getTaxFile(accountId: accountId)
  }
  
  public func getTaxFileYear(accountId: String, year: String, fileName: String) async throws -> URL {
    try await accountAPI.getTaxFileYear(accountId: accountId, year: year, fileName: fileName)
  }
  
  public func addToWaitList(waitList: String) async throws -> Bool {
    let parameter = WaitListParameter(request: WaitListParameter.Request(waitList: waitList))
    return try await accountAPI.addToWaitList(body: parameter)
  }
  
  public func getUserRewards() async throws -> [UserRewardsEntity] {
    return try await accountAPI.getUserRewards()
  }
  
  public func getFeatureConfig() async throws -> AccountFeatureConfigEntity {
    return try await accountAPI.getFeatureConfig()
  }
  
  public func createSupportTicket(title: String? = .empty, description: String? = .empty, type: String) async throws -> SupportTicketEntity {
    try await accountAPI.createSupportTicket(title: title, description: description, type: type)
  }
}
