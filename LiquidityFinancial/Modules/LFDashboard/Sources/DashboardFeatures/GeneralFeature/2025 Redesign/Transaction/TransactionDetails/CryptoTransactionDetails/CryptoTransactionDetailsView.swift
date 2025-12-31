import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities

struct CryptoTransactionDetailsView: View {
  @StateObject private var viewModel: CryptoTransactionDetailsViewModel
  let popAction: (() -> Void)?
  
  init(
    transaction: TransactionModel,
    transactionInfos: [TransactionInformation],
    isNewAddress: Bool = false,
    walletAddress: String = "",
    popAction: (() -> Void)? = nil
  ) {
    _viewModel = .init(
      wrappedValue: CryptoTransactionDetailsViewModel(
        transaction: transaction,
        transactionInfos: transactionInfos,
        isNewAddress: isNewAddress,
        address: walletAddress
      )
    )
    
    self.popAction = popAction
  }
  
  var body: some View {
    CommonTransactionDetailsView(transaction: viewModel.transaction, content: content, isCryptoBalance: true)
  }
}

// MARK: - View Components
private extension CryptoTransactionDetailsView {
  var content: some View {
    VStack(spacing: 20) {
      ForEach(viewModel.transactionInfos, id: \.self) { item in
        let isFeeLine = item.title == L10N.Common.TransactionDetails.Info.fee
        let shouldUnderline = item.title == L10N.Common.TransactionDetails.Info.hash
        let url = shouldUnderline ? viewModel.hashNetworkUrl(hash: item.value) : nil
        
        if !item.value.isEmpty || isFeeLine {
          informationCell(
            title: item.title,
            value: item.value,
            additionalValue: isFeeLine ? L10N.Common.TransactionDetails.Info.free : nil,
            isFeeLine: isFeeLine,
            shouldUnderlineValue: shouldUnderline,
            underlineUrl: url
          )
          lineView
        }
      }
    }
    .navigationLink(item: $viewModel.navigation) { item in
      switch item {
      case .receipt(let cryptoReceipt):
        CryptoTransactionReceiptView(accountID: viewModel.transaction.accountId, receipt: cryptoReceipt)
      case .saveAddress:
        SaveWalletAddressView(
          accountId: viewModel.transaction.accountId,
          walletAddress: viewModel.walletAddress,
          popAction: popAction
        )
      }
    }
    .sheetWithContentHeight(isPresented: $viewModel.showSaveWalletAddressPopup) {
      CommonBottomSheet(
        title: L10N.Common.SaveWalletAddress.Popup.title,
        subtitle: L10N.Common.SaveWalletAddress.Popup.subtitle,
        primaryButtonTitle: L10N.Common.SaveWalletAddress.Popup.title,
        secondaryButtonTitle: L10N.Common.Common.NotNow.Button.title
      ) {
        viewModel.navigatedToEnterWalletNicknameScreen()
      }
    }
  }
  
  @ViewBuilder
  func informationCell(
    title: String,
    value: String,
    additionalValue: String? = nil,
    isFeeLine: Bool = false,
    shouldUnderlineValue: Bool = false,
    underlineUrl: String? = nil
  ) -> some View {
    VStack(alignment: .leading, spacing: 20) {
      HStack(alignment: .top, spacing: 8) {
        Text(title)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundColor(Colors.grey200.swiftUIColor)
        
        Spacer()
        
        Text(value)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
          .foregroundColor(Colors.textPrimary.swiftUIColor)
          .strikethrough(isFeeLine, color: Colors.textPrimary.swiftUIColor)
          .multilineTextAlignment(.trailing)
          .applyIf(shouldUnderlineValue) {
            $0.underline()
              .onTapGesture {
                viewModel.openURL(urlString: underlineUrl)
              }
          }
        
        if let additionalValue {
          Text(additionalValue)
            .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
            .foregroundColor(isFeeLine ? Colors.successDefault.swiftUIColor : Colors.textPrimary.swiftUIColor)
        }
      }
    }
    .padding(.horizontal, 20)
  }
  
  var lineView: some View {
    Divider()
      .frame(height: 1)
      .background(Colors.greyDefault.swiftUIColor)
      .frame(maxWidth: .infinity)
  }
}
