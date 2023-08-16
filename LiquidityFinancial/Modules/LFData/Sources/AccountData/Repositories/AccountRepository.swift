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
  
  public func getTransactions(accountId: String, currencyType: String, limit: Int, offset: Int) async throws -> TransactionListEntity {
    return try await accountAPI.getTransactions(accountId: accountId, currencyType: currencyType, limit: limit, offset: offset)
  }
  
  public func getTransactionDetail(accountId: String, transactionId: String) async throws -> TransactionEntity {
    return try await accountAPI.getTransactionDetail(accountId: accountId, transactionId: transactionId)
  }
  
  public func logout() async throws -> Bool {
    return try await accountAPI.logout()
  }
}

extension APIAccount: LFAccount {}
