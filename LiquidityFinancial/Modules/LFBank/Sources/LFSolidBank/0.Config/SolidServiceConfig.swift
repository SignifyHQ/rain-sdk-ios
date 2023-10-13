import Foundation
import LFBaseBank
import Factory

@MainActor
extension Container {
  
  //Coordinator
  public var bankConfig: Factory<BankServiceConfigProtocol> {
    self {
      SolidServiceConfig()
    }
  }

}

public class SolidServiceConfig: BankServiceConfigProtocol {
  
  public private(set) var supportDisputeTransaction: Bool = false
  
}
