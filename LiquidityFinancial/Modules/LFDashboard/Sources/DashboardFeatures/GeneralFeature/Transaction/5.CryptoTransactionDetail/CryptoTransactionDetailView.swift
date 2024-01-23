import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities

struct CryptoTransactionDetailView: View {
  @StateObject private var viewModel: CryptoTransactionDetailViewModel
  let popAction: (() -> Void)?
  
  init(
    transaction: TransactionModel,
    transactionInfos: [TransactionInformation],
    isNewAddress: Bool = false,
    walletAddress: String = "",
    popAction: (() -> Void)? = nil
  ) {
    _viewModel = .init(
      wrappedValue: CryptoTransactionDetailViewModel(
        transaction: transaction,
        transactionInfos: transactionInfos,
        isNewAddress: isNewAddress,
        address: walletAddress
      )
    )
    self.popAction = popAction
  }
  
  var body: some View {
    CommonTransactionDetailView(transaction: viewModel.transaction, content: content, isCryptoBalance: true)
  }
}

// MARK: - View Components
private extension CryptoTransactionDetailView {
  var content: some View {
    VStack(spacing: 16) {
      ForEach(viewModel.transactionInfos, id: \.self) { item in
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
    .padding(.top, 16)
    .navigationLink(item: $viewModel.navigation) { item in
      switch item {
      case .receipt(let cryptoReceipt):
        CryptoTransactionReceiptView(accountID: viewModel.transaction.accountId, receipt: cryptoReceipt)
      case .saveAddress:
          EnterNicknameOfWalletView(
            accountId: viewModel.transaction.accountId,
            walletAddress: viewModel.walletAddress,
            popAction: popAction
          )
      }
    }
    .popup(isPresented: $viewModel.showSaveWalletAddressPopup) {
      saveWalletAddressPopup
    }
  }
  
  private var saveWalletAddressPopup: some View {
    LiquidityAlert(
      title: L10N.Common.TransactionDetail.SaveWalletPopup.title,
      message: L10N.Common.TransactionDetail.SaveWalletPopup.description,
      primary: .init(text: L10N.Common.TransactionDetail.SaveWalletPopup.button) {
        viewModel.navigatedToEnterWalletNicknameScreen()
      },
      secondary: .init(text: L10N.Common.Button.NotNow.title) {
        viewModel.dismissPopup()
      }
    )
  }
  
  var footer: some View {
    VStack(spacing: 16) {
      if let cryptoReceipt = viewModel.transaction.cryptoReceipt {
        FullSizeButton(
          title: L10N.Common.TransactionDetail.Receipt.button,
          isDisable: false,
          type: .secondary
        ) {
          viewModel.goToReceiptScreen(cryptoReceipt: cryptoReceipt)
        }
      }
      Text(L10N.Common.Zerohash.Disclosure.description)
        .font(Fonts.regular.swiftUIFont(size: 10))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.5))
    }
  }
}
