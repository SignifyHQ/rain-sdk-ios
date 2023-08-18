import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities

public struct WithdrawTransactionDetailView: View {
  let transaction: TransactionModel
  
  public init(transaction: TransactionModel) {
    self.transaction = transaction
  }
  
  public var body: some View {
    CommonTransactionDetailView(transaction: transaction, content: content)
  }
}

// MARK: - View Components
private extension WithdrawTransactionDetailView {
  var content: some View {
    VStack {
      GenImages.CommonImages.dash.swiftUIImage
        .foregroundColor(Colors.label.swiftUIColor)
      if let status = transaction.status {
        StatusView(status: status)
      }
    }
  }
}
