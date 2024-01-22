import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities

public struct RewardTransactionDetailView: View {
  @StateObject private var viewModel: RewardTransactionDetailViewModel
  
  public init(transaction: TransactionModel) {
    _viewModel = .init(wrappedValue: RewardTransactionDetailViewModel(transaction: transaction))
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
private extension RewardTransactionDetailView {
  var content: some View {
    VStack(spacing: 10) {
      TransactionCardView(information: viewModel.cardInformation)
        .padding(.bottom, 6)
      if viewModel.cardInformation.cardType == .crypto {
        FullSizeButton(
          title: LFLocalizable.TransactionDetail.CurrentReward.title,
          isDisable: false,
          type: .tertiary
        ) {
          // TODO: - Will be implemented later
        }
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
