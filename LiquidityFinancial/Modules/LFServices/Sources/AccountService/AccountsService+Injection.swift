import Foundation
import Factory

@MainActor
extension Container {
  
  public var fiatAccountService: Factory<AccountsServiceProtocol> {
    Factory(self) {
      DefaultAccountService()
    }
  }
}
