import Foundation
import LFBaseBank
import Factory

@MainActor
extension Container {
  
  //Coordinator
  public var bankConfig: Factory<BankServiceConfigProtocol> {
    self {
      NetspendServiceConfig()
    }
  }

}

public class NetspendServiceConfig: BankServiceConfigProtocol {
  
  public private(set) var supportDisputeTransaction: Bool = true
  
}
