import Foundation
import BankDomain

public struct APIACHInfo: ACHInfoEntity, Decodable {
  public var bankName: String?
  public var bankAddress: String?
  public var accountNumber: String?
  public var routingNumber: String?
  public var accountName: String?
}
