import Foundation
import SolidDomain
import NetworkUtilities

public struct APISolidCardTransactionsParameters: Parameterable, SolidCardTransactionParametersEntity {
  public let cardId: String
  public let currencyType: String
  public let transactionTypes: [String]
  public let limit: Int
  public let offset: Int
  
  public init(cardId: String, currencyType: String, transactionTypes: [String], limit: Int, offset: Int) {
    self.cardId = cardId
    self.currencyType = currencyType
    self.transactionTypes = transactionTypes
    self.limit = limit
    self.offset = offset
  }
}
