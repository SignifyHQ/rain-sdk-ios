import Foundation
import Factory
import AccountDomain
import CoreNetwork
import AuthorizationManager

extension Container {
  public var accountDataManager: Factory<AccountDataStorageProtocol> {
    self { AccountDataManager() }.singleton
  }
  
  public var accountAPI: Factory<AccountAPIProtocol> {
    self {
      LFCoreNetwork<AccountRoute>()
    }
  }
  
  public var accountRepository: Factory<AccountRepositoryProtocol> {
    self { AccountRepository(accountAPI: self.accountAPI.callAsFunction(), auth: self.authorizationManager.callAsFunction()) }
  }
}
