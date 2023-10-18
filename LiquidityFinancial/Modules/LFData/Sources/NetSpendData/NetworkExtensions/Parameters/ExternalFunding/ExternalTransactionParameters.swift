import Foundation
import BankDomain
import NetworkUtilities

public struct ExternalTransactionParameters: Parameterable, ExternalTransactionParametersEntity {
  public var amount: Double
  public var sourceId: String
  public var sourceType: String
  public var m2mFeeRequestId: String?
  
  public init(amount: Double, sourceId: String, sourceType: String, m2mFeeRequestId: String?) {
    self.amount = amount
    self.sourceId = sourceId
    self.sourceType = sourceType
    self.m2mFeeRequestId = m2mFeeRequestId
  }
}

public enum ExternalTransactionType: String, Codable, ExternalTransactionTypeEntity {
  case deposit
  case withdraw
  
  public var rawString: String {
    rawValue
  }
}
