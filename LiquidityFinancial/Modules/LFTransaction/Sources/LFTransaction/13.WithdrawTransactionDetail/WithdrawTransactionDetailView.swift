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
      if transaction.status != nil {
        StatusDiagramView(
          transaction: transaction,
          startTitle: LFLocalizable.TransferView.Status.Deposit.started,
          completedTitle: LFLocalizable.TransferView.Status.Deposit.completed
        )
      }
      
      if let fee = transaction.fee {
        VStack(spacing: 0) {
          GenImages.CommonImages.dash.swiftUIImage
            .foregroundColor(Colors.label.swiftUIColor)
            .padding(.bottom, 16)
          HStack {
            Text(LFLocalizable.TransferView.Status.transferFee)
              .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
              .foregroundColor(Colors.label.swiftUIColor)
            Spacer()
            Text(fee > 0 ? fee.formattedAmount(prefix: Constants.CurrencyUnit.usd.symbol) : LFLocalizable.TransferView.Status.free)
              .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.medium.value))
              .foregroundColor(Colors.label.swiftUIColor)
          }
        }
      }
      
      if let status = transaction.status {
        Spacer()
        StatusView(transactionStatus: status)
          .padding(.bottom, 16)
      }
    }
  }
}
