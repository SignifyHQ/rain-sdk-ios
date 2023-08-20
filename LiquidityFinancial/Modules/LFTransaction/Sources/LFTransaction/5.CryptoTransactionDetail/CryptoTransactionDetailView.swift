import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities

public struct CryptoTransactionDetailView: View {
  @StateObject private var viewModel: CryptoTransactionDetailViewModel
  
  public init(
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
  
  public var body: some View {
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
    .navigationLink(item: $viewModel.navigation) { _ in
      EmptyView()
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
      Button {
        viewModel.goToReceiptScreen()
      } label: {
        ArrowButton(
          image: GenImages.CommonImages.Accounts.bankStatements.swiftUIImage,
          title: LFLocalizable.TransactionDetail.Receipt.button,
          value: nil
        )
      }
      Text(LFLocalizable.Zerohash.Disclosure.description)
        .font(Fonts.regular.swiftUIFont(size: 10))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.5))
    }
  }
}
