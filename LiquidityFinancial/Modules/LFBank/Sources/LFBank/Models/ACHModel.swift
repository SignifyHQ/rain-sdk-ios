import Foundation
import LFUtilities

public struct ACHModel {
  public let accountNumber: String
  public let routingNumber: String
  public let accountName: String
  
  public init(accountNumber: String, routingNumber: String, accountName: String) {
    self.accountNumber = accountNumber
    self.routingNumber = routingNumber
    self.accountName = accountName
  }
  
  public static let `default` = ACHModel(
    accountNumber: Constants.Default.undefined.rawValue,
    routingNumber: Constants.Default.undefined.rawValue,
    accountName: Constants.Default.undefined.rawValue
  )
}
