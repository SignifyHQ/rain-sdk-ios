import Foundation
import Factory

@MainActor
extension Container {
  
  public var accountServices: Factory<AccountsServiceProtocol> {
    Factory(self) {
      DefaultAccountService()
    }
  }
  
}
