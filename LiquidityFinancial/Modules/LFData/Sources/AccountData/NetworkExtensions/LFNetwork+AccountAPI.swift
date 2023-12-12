import Foundation
import NetworkUtilities
import CoreNetwork
import LFUtilities

extension LFCoreNetwork: AccountAPIProtocol where R == AccountRoute {
  public func getUser() async throws -> APIUser {
    return try await request(AccountRoute.getUser, target: APIUser.self, failure: LFErrorObject.self, decoder: .apiDecoder)
  }
  
  public func createPassword(password: String) async throws {
    try await requestNoResponse(
      AccountRoute.createPassword(password: password),
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func changePassword(oldPassword: String, newPassword: String) async throws {
    try await requestNoResponse(
      AccountRoute.changePassword(oldPassword: oldPassword, newPassword: newPassword),
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func resetPasswordRequest(phoneNumber: String) async throws {
    try await requestNoResponse(
      AccountRoute.resetPasswordRequest(phoneNumber: phoneNumber),
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func resetPasswordVerify(phoneNumber: String, code: String) async throws {
    try await requestNoResponse(
      AccountRoute.resetPasswordVerify(phoneNumber: phoneNumber, code: code),
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func resetPassword(phoneNumber: String, password: String, token: String) async throws {
    try await requestNoResponse(
      AccountRoute.resetPassword(phoneNumber: phoneNumber, password: password, token: token),
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func loginWithPassword(phoneNumber: String, password: String) async throws -> APIPasswordLoginTokens {
    try await request(
      AccountRoute.loginWithPassword(phoneNumber: phoneNumber, password: password),
      target: APIPasswordLoginTokens.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func getAvailableRewardCurrencies() async throws -> APIAvailableRewardCurrencies {
    try await request(
      AccountRoute.getAvailableRewardCurrencies,
      target: APIAvailableRewardCurrencies.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func getSelectedRewardCurrency() async throws -> APIRewardCurrency {
    try await request(
      AccountRoute.getSelectedRewardCurrency,
      target: APIRewardCurrency.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func updateSelectedRewardCurrency(rewardCurrency: String) async throws -> APIRewardCurrency {
    try await request(
      AccountRoute.updateSelectedRewardCurrency(rewardCurrency: rewardCurrency),
      target: APIRewardCurrency.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func createZeroHashAccount() async throws -> APIZeroHashAccount {
    return try await request(AccountRoute.createZeroHashAccount, target: APIZeroHashAccount.self, failure: LFErrorObject.self, decoder: .apiDecoder)
  }
  
  public func getTransactions(accountId: String, currencyType: String, transactionTypes: String, limit: Int, offset: Int) async throws -> APITransactionList {
    let listModel = try await request(
      AccountRoute.getTransactions(accountId: accountId, currencyType: currencyType, transactionTypes: transactionTypes, limit: limit, offset: offset),
      target: APIListObject<APITransaction>.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
    return APITransactionList(total: listModel.total, data: listModel.data)
  }
  
  public func getTransactionDetail(accountId: String, transactionId: String) async throws -> APITransaction {
    try await request(
      AccountRoute.getTransactionDetail(accountId: accountId, transactionId: transactionId),
      target: APITransaction.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func logout() async throws -> Bool {
    let result = try await request(AccountRoute.logout)
    return (result.httpResponse?.statusCode ?? 500).isSuccess
  }
  
  public func createWalletAddresses(accountId: String, address: String, nickname: String) async throws -> APIWalletAddress {
    try await request(
      AccountRoute.createWalletAddress(accountId: accountId, address: address, nickname: nickname),
      target: APIWalletAddress.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func getWalletAddresses(accountId: String) async throws -> [APIWalletAddress] {
    let listModel = try await request(
      AccountRoute.getWalletAddresses(accountId: accountId),
      target: APIListObject<APIWalletAddress>.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
    return listModel.data
  }
  
  public func updateWalletAddresses(accountId: String, walletId: String, walletAddress: String, nickname: String) async throws -> APIWalletAddress {
    try await request(
      AccountRoute.updateWalletAddress(accountId: accountId, walletId: walletId, walletAddress: walletAddress, nickname: nickname),
      target: APIWalletAddress.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func deleteWalletAddresses(accountId: String, walletAddress: String) async throws -> APIDeleteWalletResponse {
    let result = try await request(
      AccountRoute.deleteWalletAddresses(
        accountId: accountId,
        walletAddress: walletAddress
      )
    )
    let statusCode = result.httpResponse?.statusCode ?? 500
    return APIDeleteWalletResponse(success: statusCode.isSuccess)
  }
  
  public func getReferralCampaign() async throws -> APIReferralCampaign {
    return try await request(
      AccountRoute.getReferralCampaign,
      target: APIReferralCampaign.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func addToWaitList(body: WaitListParameter) async throws -> Bool {
    let result = try await request(
      AccountRoute.addToWaitList(body: body)
    )
    let statusCode = result.httpResponse?.statusCode ?? 500
    return statusCode.isSuccess
  }
  
  public func getUserRewards() async throws -> [APIUserRewards] {
    return try await request(
      AccountRoute.getUserRewards,
      target: [APIUserRewards].self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func getFeatureConfig() async throws -> APIAccountFeatureConfig {
    return try await request(
      AccountRoute.getFeatureConfig,
      target: APIAccountFeatureConfig.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func createSupportTicket(title: String?, description: String?, type: String) async throws -> APISupportTicket {
    try await request(
      AccountRoute.createSupportTicket(title: title, description: description, type: type),
      target: APISupportTicket.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func getMigrationStatus() async throws -> APIMigrationStatus {
    try await request(
      .getMigrationStatus,
      target: APIMigrationStatus.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func requestMigration() async throws -> APIMigrationStatus {
    try await request(
      .requestMigration,
      target: APIMigrationStatus.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
}
