import Foundation

public struct DefaultAccountService: AccountsServiceProtocol {
  
  public init() {
  }
  
  public func getFiatAccounts() -> [AccountModel] {
    []
  }
  
}
