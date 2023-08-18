import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities

public struct GasFeeTransactionDetailView: View {
  @State private var isNavigateToReceiptView = false
  let transaction: TransactionModel
  
  public init(transaction: TransactionModel) {
    self.transaction = transaction
  }
  
  public var body: some View {
    CommonTransactionDetailView(transaction: transaction, content: content)
      .navigationLink(isActive: $isNavigateToReceiptView) {
        EmptyView() // TODO: Will be replaced by ReceiptView
      }
  }
}

// MARK: - View Components
private extension GasFeeTransactionDetailView {
  var content: some View {
    VStack(spacing: 10) {
      FullSizeButton(
        title: LFLocalizable.TransactionDetail.CurrentReward.title,
        isDisable: false,
        type: .tertiary
      ) {
        // TODO: - Will be implemented later
      }
      FullSizeButton(
        title: LFLocalizable.TransactionDetail.Receipt.button,
        isDisable: false,
        type: .secondary
      ) {
        isNavigateToReceiptView = true
      }
    }
  }
}
