import Foundation
import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities
import Services

public struct TransactionDetailView: View {
  @StateObject private var viewModel: TransactionDetailViewModel
  let kind: TransactionDetailType?
  let isNewAddress: Bool?
  let walletAddress: String?
  let transactionInfo: [TransactionInformation]?
  let isPopToRoot: Bool
  let popAction: (() -> Void)?
  
  public init(
    transactionId: String,
    fundraisersId: String = .empty,
    kind: TransactionDetailType? = nil,
    isNewAddress: Bool? = nil,
    walletAddress: String? = nil,
    transactionInfo: [TransactionInformation]? = nil,
    isPopToRoot: Bool = true,
    popAction: (() -> Void)? = nil
  ) {
    _viewModel = .init(
      wrappedValue: TransactionDetailViewModel(
        transactionId: transactionId,
        fundraisersId: fundraisersId,
        kind: kind)
    )
    self.kind = kind
    self.isPopToRoot = isPopToRoot
    self.isNewAddress = isNewAddress
    self.walletAddress = walletAddress
    self.transactionInfo = transactionInfo
    self.popAction = popAction
  }
  
  public var body: some View {
    ZStack {
      if viewModel.isFetchingData {
        LottieView(loading: .primary)
          .frame(width: 30, height: 20)
      } else {
        Group {
          transactionContent(kind: kind ?? viewModel.transaction.detailType)
        }
      }
    }
    .frame(max: .infinity)
    .navigationBarBackButtonHidden(isPopToRoot)
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        Button {
          if let popAction = popAction {
            popAction()
          } else {
            LFUtilities.popToRootView()
          }
        } label: {
          GenImages.CommonImages.icBack.swiftUIImage
        }
        .opacity(isPopToRoot ? 1 : 0)
      }
    }
    .background(Colors.background.swiftUIColor)
    .edgesIgnoringSafeArea(.bottom)
    .track(name: String(describing: type(of: self)))
  }
}

extension TransactionDetailView {
  
  @ViewBuilder func transactionContent(kind: TransactionDetailType) -> some View {
    switch kind {
    case .common:
      CommonTransactionDetailView(transaction: viewModel.transaction)
    case .deposit:
      DepositTransactionDetailView(transaction: viewModel.transaction)
    case .crypto:
      CryptoTransactionDetailView(
        transaction: viewModel.transaction,
        transactionInfos: transactionInfo ?? viewModel.cryptoTransactions,
        isNewAddress: isNewAddress ?? false,
        walletAddress: walletAddress ?? .empty,
        popAction: popAction
      )
    case .withdraw:
      WithdrawTransactionDetailView(transaction: viewModel.transaction)
    case .purchase:
      PurchaseTransactionDetailView(transaction: viewModel.transaction)
    case .refund:
      RefundTransactionDetailView(
        transaction: viewModel.transaction,
        transactionInfos: LFUtilities.cryptoEnabled ? viewModel.refundCryptoTransactions : viewModel.refundTransactions
      )
    case .donation:
      DonationTransactionDetailView(donation: viewModel.donation)
    case .cashback:
      CashbackTransactionDetail(transaction: viewModel.transaction)
    case .reward:
        RewardReversalTransactionDetailView(
          transaction: viewModel.transaction,
          transactionInfos: viewModel.rewardTransactions
        )
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
