import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities

public struct GasFeeTransactionDetailView: View {
  @StateObject private var viewModel: GasFeeTransactionDetailViewModel
  
  public init(transaction: TransactionModel) {
    _viewModel = .init(wrappedValue: GasFeeTransactionDetailViewModel(transaction: transaction))
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
private extension GasFeeTransactionDetailView {
  var content: some View {
    VStack(spacing: 16) {
      Spacer()
      if let status = viewModel.transaction.status {
        StatusView(transactionStatus: status)
      }
      
      if let receiptType = viewModel.transaction.receipt?.type {
        FullSizeButton(
          title: L10N.Common.TransactionDetail.Receipt.button,
          isDisable: false,
          type: .secondary
        ) {
          viewModel.goToReceiptScreen(receiptType: receiptType)
        }
      }
      
//      Text(L10N.Common.Zerohash.Disclosure.description)
//        .font(Fonts.regular.swiftUIFont(size: 10))
//        .foregroundColor(Colors.label.swiftUIColor.opacity(0.5))
    }
  }
}
