import Foundation
import NetworkUtilities
import AccountDomain

public struct APITransactionsParameters: Parameterable, TransactionsParametersEntity {
  public var currencyType: String
  public var transactionTypes: [String]
  public var limit: Int
  public var offset: Int
  public var contractAddress: String?

  public init(
    currencyType: String,
    transactionTypes: [String],
    limit: Int,
    offset: Int,
    contractAddress: String? = nil
  ) {
    self.currencyType = currencyType
    self.transactionTypes = transactionTypes
    self.limit = limit
    self.offset = offset
    self.contractAddress = contractAddress
  }
}
