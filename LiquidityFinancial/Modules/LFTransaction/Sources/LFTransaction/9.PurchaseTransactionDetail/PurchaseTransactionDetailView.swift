import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities

public struct PurchaseTransactionDetailView: View {
  @StateObject private var viewModel: PurchaseTransactionDetailViewModel
  
  public init(transaction: TransactionModel) {
    _viewModel = .init(wrappedValue: PurchaseTransactionDetailViewModel(transaction: transaction))
  }
  
  public var body: some View {
    CommonTransactionDetailView(transaction: viewModel.transaction, content: content)
      .navigationLink(item: $viewModel.navigation) { item in
        switch item {
        case let .cryptoReceipt(receipt):
          CryptoTransactionReceiptView(accountID: viewModel.transaction.id, receipt: receipt)
        case let .donationReceipt(receipt):
          DonationTransactionReceiptView(accountID: viewModel.transaction.id, receipt: receipt)
        }
      }
  }
}

// MARK: - View Components
private extension PurchaseTransactionDetailView {
  var content: some View {
    VStack(spacing: 24) {
      if viewModel.transaction.rewards != nil {
        TransactionCardView(information: viewModel.cardInformation)
      }
      if let receiptType = viewModel.transaction.receipt?.type {
        FullSizeButton(
          title: LFLocalizable.TransactionDetail.Receipt.button,
          isDisable: false,
          type: .secondary
        ) {
          viewModel.goToReceiptScreen(receiptType: receiptType)
        }
      }
    }
  }
}
