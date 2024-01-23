import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities

public struct RewardReversalTransactionDetailView: View {
  @StateObject private var viewModel: RewardReversalTransactionDetailViewModel
  
  let transactionInfos: [TransactionInformation]
  
  public init(transaction: TransactionModel, transactionInfos: [TransactionInformation]) {
    _viewModel = .init(wrappedValue: RewardReversalTransactionDetailViewModel(transaction: transaction))
    self.transactionInfos = transactionInfos
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
private extension RewardReversalTransactionDetailView {
  var content: some View {
    VStack(spacing: 24) {
      ForEach(transactionInfos, id: \.self) { item in
        GenImages.CommonImages.dash.swiftUIImage
          .foregroundColor(Colors.label.swiftUIColor)
        TransactionInformationCell(item: item)
      }
      Spacer()
      if let status = viewModel.transaction.status {
        StatusView(transactionStatus: status)
      }
      footer
    }
  }
  
  var footer: some View {
    VStack(spacing: 16) {
      if let receiptType = viewModel.transaction.receipt?.type {
        FullSizeButton(
          title: L10N.Common.TransactionDetail.Receipt.button,
          isDisable: false,
          type: .secondary
        ) {
          viewModel.goToReceiptScreen(receiptType: receiptType)
        }
      }
      Text(L10N.Common.Zerohash.Disclosure.description)
        .font(Fonts.regular.swiftUIFont(size: 10))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.5))
    }
  }
}
