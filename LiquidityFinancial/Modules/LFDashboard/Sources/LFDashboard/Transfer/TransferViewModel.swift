import Foundation
import NetSpendData
import SwiftUI
import LFStyleGuide
import LFLocalizable

@MainActor
class TransferViewModel: ObservableObject {
  let transfer: Transfer
  let contact: ContactDataModel

  init(transfer: Transfer, contact: ContactDataModel) {
    self.transfer = transfer
    self.contact = contact
  }

  var isPending: Bool {
    transfer.status?.isPending ?? true
  }

  var navigationTitle: String {
    transfer.txnType == .credit ? LFLocalizable.TransferView.credit :
    LFLocalizable.TransferView.debit
  }

  var title: String {
    isPending ? transferStarted : transferCompleted
  }

  private var transferStarted: String {
    transfer.txnType == .credit ? LFLocalizable.TransferView.creditStarted :
    LFLocalizable.TransferView.debitStarted
  }

  private var transferCompleted: String {
    transfer.txnType == .credit ? LFLocalizable.TransferView.creditCompleted :
    LFLocalizable.TransferView.debitCompleted
  }

  var amount: String {
    let prefix = transfer.txnType == .credit ? "+" : "-"
    let amount = transfer.amount?.formattedAmount(prefix: "$", minFractionDigits: 2) ?? ""
    return "\(prefix)\(amount)"
  }

  var amountColor: Color {
    if transfer.status == TransactionStatus.pending {
      return Colors.pending.swiftUIColor
    } else if transfer.txnType == .credit {
      return Colors.green.swiftUIColor
    } else {
      return Colors.error.swiftUIColor
    }
  }

  var subtitle: String {
    if let card = contact.debitCard {
      return LFLocalizable.TransferView.debitCard(card.last4 ?? "")
    } else {
      return LFLocalizable.TransferView.checking(contact.ach?.last4accountnumber ?? "")
    }
  }
}
