import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities

struct CryptoTransactionDetailView: View {
  @StateObject private var viewModel: CryptoTransactionDetailViewModel
  
  init(
    transaction: TransactionModel,
    transactionInfos: [TransactionInformation],
    isNewAddress: Bool = false,
    walletAddress: String = ""
  ) {
    _viewModel = .init(
      wrappedValue: CryptoTransactionDetailViewModel(
        transaction: transaction,
        transactionInfos: transactionInfos,
        isNewAddress: isNewAddress,
        address: walletAddress
      )
    )
  }
  
  var body: some View {
    CommonTransactionDetailView(transaction: viewModel.transaction, content: content)
  }
}

// MARK: - View Components
private extension CryptoTransactionDetailView {
  var content: some View {
    VStack(spacing: 24) {
      ForEach(viewModel.transactionInfos, id: \.self) { item in
        GenImages.CommonImages.dash.swiftUIImage
          .foregroundColor(Colors.label.swiftUIColor)
        TransactionInformationCell(item: item)
      }
      Spacer()
      if let status = viewModel.transaction.status {
        StatusView(status: status)
      }
      footer
    }
    .navigationLink(item: $viewModel.navigation) { item in
      switch item {
      case .receipt(let cryptoReceipt):
        CryptoTransactionReceiptView(accountID: viewModel.transaction.accountId, receipt: cryptoReceipt)
      case .saveAddress(let address):
        EmptyView() // TODO: Will be implemented later
      }
    }
    .popup(isPresented: $viewModel.showSaveWalletAddressPopup) {
      saveWalletAddressPopup
    }
  }
  
  private var saveWalletAddressPopup: some View {
    LiquidityAlert(
      title: LFLocalizable.TransactionDetail.SaveWalletPopup.title,
      message: LFLocalizable.TransactionDetail.SaveWalletPopup.description,
      primary: .init(text: LFLocalizable.TransactionDetail.SaveWalletPopup.button) {
        viewModel.navigatedToEnterWalletNicknameScreen()
      },
      secondary: .init(text: LFLocalizable.Button.NotNow.title) {
        viewModel.dismissPopup()
      }
    )
  }
  
  var footer: some View {
    VStack(spacing: 16) {
      if let cryptoReceipt = viewModel.transaction.cryptoReceipt {
        ArrowButton(
          image: GenImages.CommonImages.Accounts.bankStatements.swiftUIImage,
          title: LFLocalizable.TransactionDetail.Receipt.button,
          value: nil
        ) {
          viewModel.goToReceiptScreen(cryptoReceipt: cryptoReceipt)
        }
      }
      Text(LFLocalizable.Zerohash.Disclosure.description)
        .font(Fonts.regular.swiftUIFont(size: 10))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.5))
    }
  }
}
