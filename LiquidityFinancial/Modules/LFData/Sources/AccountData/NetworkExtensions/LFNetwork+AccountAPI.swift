import Foundation
import NetworkUtilities
import CoreNetwork
import LFUtilities

extension LFCoreNetwork: AccountAPIProtocol where R == AccountRoute {
  public func getAccount(currencyType: String) async throws -> [APIAccount] {
    return try await request(AccountRoute.getAccount(currencyType: currencyType), target: [APIAccount].self, failure: LFErrorObject.self, decoder: .apiDecoder)
  }
  
  public func getUser() async throws -> APIUser {
    return try await request(AccountRoute.getUser, target: APIUser.self, failure: LFErrorObject.self, decoder: .apiDecoder)
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
}
