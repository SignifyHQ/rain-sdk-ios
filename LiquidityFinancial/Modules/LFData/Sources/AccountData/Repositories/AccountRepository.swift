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
  
  public func getAccount(currencyType: String) async throws -> [LFAccount] {
    return try await accountAPI.getAccount(currencyType: currencyType)
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
}

extension APIAccount: LFAccount {}
