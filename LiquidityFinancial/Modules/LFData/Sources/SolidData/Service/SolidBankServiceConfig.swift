import Foundation
import BankService
import Factory

public class SolidBankService: BankServiceProtocol {
  public private(set) var supportDisputeTransaction: Bool = false
  
  public init() {}
}
