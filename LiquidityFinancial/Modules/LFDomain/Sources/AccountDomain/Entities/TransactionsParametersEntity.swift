import Foundation

// sourcery: AutoMockable
public protocol TransactionsParametersEntity {
  var currencyType: String { get }
  var transactionTypes: [String] { get }
  var limit: Int { get }
  var offset: Int { get }
  var contractAddress: String? { get }
  var currency: String? { get }
}
