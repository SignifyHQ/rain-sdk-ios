import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities

struct WithdrawTransactionDetailView: View {
  let transaction: TransactionModel
  
  init(transaction: TransactionModel) {
    self.transaction = transaction
  }
  
  var body: some View {
    CommonTransactionDetailView(transaction: transaction, content: content)
  }
}

// MARK: - View Components
private extension WithdrawTransactionDetailView {
  var content: some View {
    VStack(spacing: 32) {
      GenImages.CommonImages.dash.swiftUIImage
        .foregroundColor(Colors.label.swiftUIColor)
      if let status = transaction.status {
        StatusDiagramView(
          transaction: transaction,
          startTitle: LFLocalizable.TransferView.Status.Withdraw.started,
          completedTitle: LFLocalizable.TransferView.Status.Withdraw.completed
        )
        Spacer()
        StatusView(status: status)
      }
    }
  }
}
