import Foundation

public protocol DepositParametersEntity {
  var amount: Double { get }
  var sourceId: String { get }
  var sourceType: String { get }
}
