import Foundation
import NetSpendDomain
import DataUtilities

public struct ExternalTransactionParameters: Parameterable, ExternalTransactionParametersEntity {
  public var amount: Double
  public var sourceId: String
  public var sourceType: String
  
  public init(amount: Double, sourceId: String, sourceType: String) {
    self.amount = amount
    self.sourceId = sourceId
    self.sourceType = sourceType
  }
}

public enum ExternalTransactionType: String, Codable, ExternalTransactionTypeEntity {
  case deposit
  case withdraw
  
  public var rawString: String {
    rawValue
  }
}
