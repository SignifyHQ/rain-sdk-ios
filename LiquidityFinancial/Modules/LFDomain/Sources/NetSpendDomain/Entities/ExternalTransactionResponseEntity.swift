import Foundation

public protocol ExternalTransactionResponseEntity {
  var transactionId: String { get }
  var externalTransferId: String { get }
}
