import Foundation
import AuthorizationManager
import AccountDomain
import OnboardingDomain
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
  
  public func createPassword(password: String) async throws {
    try await accountAPI.createPassword(password: password)
  }
  
  public func changePassword(oldPassword: String, newPassword: String) async throws {
    try await accountAPI.changePassword(oldPassword: oldPassword, newPassword: newPassword)
  }
  
  public func resetPasswordRequest(phoneNumber: String) async throws {
    try await accountAPI.resetPasswordRequest(phoneNumber: phoneNumber)
  }
  
  public func resetPasswordVerify(phoneNumber: String, code: String) async throws -> PasswordResetTokenEntity {
    try await accountAPI.resetPasswordVerify(phoneNumber: phoneNumber, code: code)
  }
  
  public func resetPassword(phoneNumber: String, password: String, token: String) async throws {
    try await accountAPI.resetPassword(phoneNumber: phoneNumber, password: password, token: token)
  }
  
  public func loginWithPassword(phoneNumner: String, password: String) async throws -> AccessTokensEntity {
    let tokens = try await accountAPI.loginWithPassword(phoneNumber: phoneNumner, password: password)
    auth.refreshWith(apiToken: tokens)
    
    return tokens
  }
  
  public func verifyEmailRequest() async throws {
    try await accountAPI.verifyEmailRequest()
  }
  
  public func verifyEmail(code: String) async throws {
    try await accountAPI.verifyEmail(code: code)
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
  
  public func getMigrationStatus() async throws -> MigrationStatusEntity {
    try await accountAPI.getMigrationStatus()
  }
  
  public func requestMigration() async throws -> MigrationStatusEntity {
    try await accountAPI.requestMigration()
  }
  
  public func getSecretKey() async throws -> SecretKeyEntity {
    try await accountAPI.getSecretKey()
  }
  
  public func enableMFA(code: String) async throws -> EnableMFAEntity {
    try await accountAPI.enableMFA(code: code)
  }
  
  public func disableMFA(code: String) async throws -> DisableMFAEntity {
    try await accountAPI.disableMFA(code: code)
  }
}
