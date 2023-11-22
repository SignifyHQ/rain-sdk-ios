import Foundation
import BankService
import Factory

public class NetspendBankService: BankServiceProtocol {
  public private(set) var supportDisputeTransaction: Bool = true
  
  public init() {}
}
