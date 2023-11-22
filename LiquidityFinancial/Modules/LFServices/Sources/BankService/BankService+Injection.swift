import Foundation
import Factory

@MainActor
extension Container {
  
  public var bankServiceConfig: Factory<BankServiceProtocol> {
    self {
      DefaultBankService()
    }
  }
  
}
