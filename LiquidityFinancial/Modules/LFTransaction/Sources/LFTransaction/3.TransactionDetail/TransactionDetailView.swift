import Foundation
import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities

/*
 This struct only use when open from list transaction.
 Transactions were opened from other actions please use specific transaction type
 */
public struct TransactionDetailView: View {
  @StateObject private var viewModel: TransactionDetailViewModel
  let kind: TransactionDetailType
  
  public init(accountID: String, transactionId: String, kind: TransactionDetailType) {
    _viewModel = .init(wrappedValue: TransactionDetailViewModel(accountID: accountID, transactionId: transactionId))
    self.kind = kind
  }
  
  public var body: some View {
    ZStack {
      if viewModel.isFetchingData {
        LottieView(loading: .primary)
          .frame(width: 30, height: 20)
      } else {
        Group {
          switch kind {
          case .common:
            CommonTransactionDetailView(transaction: viewModel.transaction)
          case .deposit:
            DepositTransactionDetailView(transaction: viewModel.transaction)
          case .crypto:
            CryptoTransactionDetailView(transaction: viewModel.transaction, transactionInfos: viewModel.cryptoTransactions)
          case .withdraw:
            WithdrawTransactionDetailView(transaction: viewModel.transaction)
          case .purchase:
            PurchaseTransactionDetailView(transaction: viewModel.transaction)
          case .refund:
            RefundTransactionDetailView(
              transaction: viewModel.transaction,
              transactionInfos: LFUtility.cryptoEnabled ? viewModel.refundCryptoTransactions : viewModel.refundTransactions
            )
          case .donation:
            DonationTransactionDetailView(transaction: viewModel.transaction)
          case .cashback:
            CashbackTransactionDetail(transaction: viewModel.transaction)
          case .reward:
            RewardTransactionDetailView(transaction: viewModel.transaction)
          case .rewardReversal:
            RewardReversalTransactionDetailView(
              transaction: viewModel.transaction,
              transactionInfos: viewModel.rewardTransactions
            )
          case .fee:
            GasFeeTransactionDetailView(transaction: viewModel.transaction)
          }
        }
      }
    }
    .frame(max: .infinity)
    .background(Colors.background.swiftUIColor)
  }
}
