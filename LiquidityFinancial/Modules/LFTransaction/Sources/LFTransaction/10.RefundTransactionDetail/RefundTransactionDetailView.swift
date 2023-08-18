import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities

public struct RefundTransactionDetailView: View {
  let transaction: TransactionModel
  let transactionInfos: [TransactionInformation]
  
  public init(transaction: TransactionModel, transactionInfos: [TransactionInformation]) {
    self.transaction = transaction
    self.transactionInfos = transactionInfos
  }
  
  public var body: some View {
    CommonTransactionDetailView(transaction: transaction, content: content)
  }
}

// MARK: - View Components
private extension RefundTransactionDetailView {
  var content: some View {
    VStack(spacing: 24) {
      ForEach(transactionInfos, id: \.self) { item in
        GenImages.CommonImages.dash.swiftUIImage
          .foregroundColor(Colors.label.swiftUIColor)
        TransactionInformationCell(item: item)
      }
      Spacer()
      if let status = transaction.status {
        StatusView(status: status)
      }
    }
  }
}
