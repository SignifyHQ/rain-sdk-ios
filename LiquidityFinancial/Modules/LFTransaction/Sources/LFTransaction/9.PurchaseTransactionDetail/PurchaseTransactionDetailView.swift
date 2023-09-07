import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities
import LFServices

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
        case let .disputeTransaction(netspendAccountID, passcode):
          NetspendDisputeTransactionViewController(netspendAccountID: netspendAccountID, passcode: passcode) {
            viewModel.navigation = nil
          }
          .navigationBarHidden(true)
        case .rewardCampaigns:
          CurrentRewardView()
        }
      }
  }
}

// MARK: - View Components
private extension PurchaseTransactionDetailView {
  var content: some View {
    VStack {
      if viewModel.transaction.rewards != nil {
        TransactionCardView(information: viewModel.cardInformation)
          .padding(.bottom, 12)
      }
      Spacer()
      VStack(spacing: 10) {
        if LFUtility.cryptoEnabled {
          if viewModel.transaction.rewards != nil {
            FullSizeButton(
              title: LFLocalizable.TransactionDetail.CurrentReward.title,
              isDisable: false,
              type: .tertiary
            ) {
              viewModel.onClickedCurrentRewardButton()
            }
          }
          FullSizeButton(
            title: LFLocalizable.Button.DisputeTransaction.title,
            isDisable: false,
            isLoading: $viewModel.isLoadingDisputeTransaction,
            type: .tertiary
          ) {
            viewModel.getDisputeAuthorizationCode()
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
}
