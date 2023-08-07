import Foundation
import NetSpendDomain
import DataUtilities

public struct DepositParameters: Parameterable, DepositParametersEntity {
  public var amount: Double
  public var sourceId: String
  public var sourceType: String
  
  public init(amount: Double, sourceId: String, sourceType: String) {
    self.amount = amount
    self.sourceId = sourceId
    self.sourceType = sourceType
  }
}
