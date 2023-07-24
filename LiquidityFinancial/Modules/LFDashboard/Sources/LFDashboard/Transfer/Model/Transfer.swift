import Foundation
import LFUtilities

struct Transfer: Codable {
  var id: String?
  var amount: String?
  var status: TransactionStatus?
  var txnType: TransactionType?
  var transferType: TransferType?
  var transferredAt: String?
  var createdAt: String?
  var estimatedTxnDate: String?
  var cancellationDate: String?

  var transactionDateInLocalZone: String {
    guard let transDate = transferredAt?.nilIfEmpty else {
      return ""
    }
    return transDate.serverToTransactionDisplay()
  }
}
