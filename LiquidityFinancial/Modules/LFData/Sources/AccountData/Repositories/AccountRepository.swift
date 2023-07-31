import Foundation
import AuthorizationManager
import AccountDomain

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
  
  public func getUser(deviceId: String) async throws -> LFUser {
    return try await accountAPI.getUser(deviceId: deviceId)
  }
  
  public func getAccount(currencyType: String) async throws -> LFAccount {
    return try await accountAPI.getAccount(currencyType: currencyType)
  }
}

extension APIAccount: LFAccount {}
