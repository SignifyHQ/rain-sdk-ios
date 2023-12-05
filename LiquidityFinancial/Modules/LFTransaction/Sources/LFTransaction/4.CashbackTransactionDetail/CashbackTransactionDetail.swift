import Foundation
import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities

struct CashbackTransactionDetail: View {
  let transaction: TransactionModel
  
  init(transaction: TransactionModel) {
    self.transaction = transaction
  }
  
  var body: some View {
    CommonTransactionDetailView(transaction: transaction, content: content)
  }
}

// MARK: - View Components
private extension CashbackTransactionDetail {
  var content: some View {
    VStack(spacing: 32) {
      GenImages.CommonImages.dash.swiftUIImage
        .foregroundColor(Colors.label.swiftUIColor)
      if let status = transaction.status {
        StatusDiagramView(
          transaction: transaction,
          startTitle: LFLocalizable.TransferView.RewardsStatus.pending,
          completedTitle: LFLocalizable.TransferView.RewardsStatus.completed
        )
        Spacer()
        StatusView(transactionStatus: status)
          .padding(.bottom, 16)
      }
    }
  }
}
