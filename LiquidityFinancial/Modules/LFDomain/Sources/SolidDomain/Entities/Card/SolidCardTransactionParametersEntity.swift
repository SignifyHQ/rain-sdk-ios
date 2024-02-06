import Foundation

// sourcery: AutoMockable
public protocol SolidCardTransactionParametersEntity {
  var cardId: String { get }
  var currencyType: String { get }
  var transactionTypes: [String] { get }
  var limit: Int { get }
  var offset: Int { get }
}
