import Foundation
import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities
import Services

public struct TransactionDetailsView: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel: TransactionDetailsViewModel
  let kind: TransactionDetailType?
  let isNewAddress: Bool?
  let walletAddress: String?
  let transactionInfo: [TransactionInformation]?
  let isPopToRoot: Bool
  let popAction: (() -> Void)?
  
  public init(
    method: TransactionDetailsViewModel.Method,
    fundraisersId: String = .empty,
    kind: TransactionDetailType? = nil,
    isNewAddress: Bool? = nil,
    walletAddress: String? = nil,
    transactionInfo: [TransactionInformation]? = nil,
    isPopToRoot: Bool = true,
    popAction: (() -> Void)? = nil
  ) {
    _viewModel = .init(
      wrappedValue: TransactionDetailsViewModel(
        method: method,
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
    Group {
      if viewModel.transaction == TransactionModel.default {
        DefaultLottieView(loading: .branded)
          .frame(width: 52, height: 52)
      } else {
        ScrollView(showsIndicators: false) {
          VStack(
            spacing: 24
          ) {
            transactionContent(kind: kind ?? viewModel.transaction.detailType)
            
            FullWidthButton(
              title: L10N.Common.Common.Close.Button.title
            ) {
              isPopToRoot ? dismissAction() : dismiss()
            }
          }
        }
      }
    }
    .appNavBar(
      navigationTitle: L10N.Common.TransactionDetails.Screen.title,
      // Hide back button in case we need to pop to root
      // since in this case native swipe-to-dismiss is disabled.
      // User can dismiss the screen by tapping the Close button in the bottom
      isBackButtonHidden: isPopToRoot
    )
    .padding(.horizontal, 24)
    .padding(.top, 4)
    .toast(data: $viewModel.toastData)
    .frame(max: .infinity)
    .background(Colors.baseAppBackground2.swiftUIColor)
    .track(name: String(describing: type(of: self)))
  }
}

extension TransactionDetailsView {
  @ViewBuilder func transactionContent(kind: TransactionDetailType) -> some View {
    CryptoTransactionDetailsView(
      transaction: viewModel.transaction,
      transactionInfos: transactionInfo ?? viewModel.cryptoTransactions,
      isNewAddress: isNewAddress ?? false,
      walletAddress: walletAddress ?? .empty,
      popAction: popAction
    )
  }
}

// MARK: - Helper Methods
extension TransactionDetailsView {
  func dismissAction() {
    if let popAction = popAction {
      popAction()
    } else{
      LFUtilities.popToRootView()
    }
  }
}
