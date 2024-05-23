import Foundation
import AuthorizationManager
import AccountDomain
import OnboardingDomain
import LFUtilities

public class AccountRepository: AccountRepositoryProtocol {
  private let accountDataManager: AccountDataStorageProtocol
  private let accountAPI: AccountAPIProtocol
  private let auth: AuthorizationManagerProtocol
  
  public init(
    accountDataManager: AccountDataStorageProtocol,
    accountAPI: AccountAPIProtocol,
    auth: AuthorizationManagerProtocol
  ) {
    self.accountDataManager = accountDataManager
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
    auth.savePortalSessionToken(token: tokens.portalSessionToken)
    
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
  
  public func getTransactions(parameters: TransactionsParametersEntity) async throws -> TransactionListEntity {
    guard let parameters = parameters as? APITransactionsParameters else {
      throw "Can't map paramater :\(parameters)"
    }
    return try await accountAPI.getTransactions(parameters: parameters)
  }
  
  public func getTransactionDetail(transactionId: String) async throws -> TransactionEntity {
    return try await accountAPI.getTransactionDetail(transactionId: transactionId)
  }
  
  public func getTransactionDetailByHashID(transactionHash: String) async throws -> TransactionEntity {
    return try await accountAPI.getTransactionDetailByHashID(transactionHash: transactionHash)
  }
  
  public func logout() async throws -> Bool {
    return try await accountAPI.logout()
  }
  
  public func createWalletAddresses(address: String, nickname: String) async throws -> WalletAddressEntity {
    guard let userID = accountDataManager.userInfomationData.userID else { throw LiquidityError.invalidData }
    
    return try await accountAPI.createWalletAddresses(accountId: userID, address: address, nickname: nickname)
  }
  
  public func updateWalletAddresses(walletId: String, walletAddress: String, nickname: String) async throws -> WalletAddressEntity {
    guard let userID = accountDataManager.userInfomationData.userID else { throw LiquidityError.invalidData }
    
    return try await accountAPI.updateWalletAddresses(
      accountId: userID,
      walletId: walletId,
      walletAddress: walletAddress,
      nickname: nickname
    )
  }
  
  public func getWalletAddresses() async throws -> [WalletAddressEntity] {
    guard let userID = accountDataManager.userInfomationData.userID else { throw LiquidityError.invalidData }
    return try await accountAPI.getWalletAddresses(accountId: userID)
  }
  
  public func deleteWalletAddresses(walletAddress: String) async throws -> DeleteWalletEntity {
    guard let userID = accountDataManager.userInfomationData.userID else { throw LiquidityError.invalidData }
    return try await accountAPI.deleteWalletAddresses(accountId: userID, walletAddress: walletAddress)
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
