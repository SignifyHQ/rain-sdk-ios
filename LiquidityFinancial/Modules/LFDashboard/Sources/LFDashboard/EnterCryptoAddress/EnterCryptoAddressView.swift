import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide
import AccountDomain
import CodeScanner

struct EnterCryptoAddressView: View {
  @StateObject private var viewModel: EnterCryptoAddressViewModel
  
  init(account: LFAccount, amount: Double) {
    _viewModel = .init(wrappedValue: EnterCryptoAddressViewModel(account: account, amount: amount))
  }
  
  var body: some View {
    VStack(alignment: .leading, spacing: 32) {
      header
      VStack(alignment: .leading, spacing: 12) {
        textField
        warningLabel
      }
      Spacer()
      footer
    }
    .padding(.horizontal, 30)
    .padding(.bottom, 20)
    .frame(maxWidth: .infinity)
    .background(Colors.background.swiftUIColor)
    .popup(item: $viewModel.toastMessage, style: .toast) {
      ToastView(toastMessage: $0)
    }
    .onTapGesture {
      hideKeyboard()
    }
    .navigationBarTitleDisplayMode(.inline)
    .sheet(isPresented: $viewModel.isShowingScanner) {
      CodeScannerView(codeTypes: [.qr], simulatedData: "") { result in
        viewModel.handleScan(result: result)
      }
    }
    .navigationLink(item: $viewModel.navigation) { item in
      switch item {
      case .confirm:
        ConfirmSendCryptoView(
          accountId: viewModel.account.id,
          amount: viewModel.amount,
          address: viewModel.inputValue
        )
      }
    }
  }
}

// MARK: - View Components
private extension EnterCryptoAddressView {
  var header: some View {
    ZStack(alignment: .topLeading) {
      VStack(spacing: 0) {
        titleView
      }
    }
  }
  
  @ViewBuilder var titleView: some View {
    VStack(spacing: 10) {
      Text(LFLocalizable.EnterCryptoAddressView.title(LFLocalizable.Crypto.value.uppercased()))
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .foregroundColor(Colors.label.swiftUIColor)
    }
  }
  
  var textField: some View {
    WalletAddressTextField(
      placeHolderText: LFLocalizable.EnterCryptoAddressView.WalletAddress.placeholder,
      value: $viewModel.inputValue,
      textFieldTitle: LFLocalizable.EnterCryptoAddressView.WalletAddress
        .title(LFLocalizable.Crypto.value),
      clearValue: {
        viewModel.clearValue()
      },
      scanTap: {
        viewModel.scanAddressTap()
      }
    )
  }
  
  var warningLabel: some View {
    Text(LFLocalizable.EnterCryptoAddressView.warning(LFLocalizable.Crypto.value))
      .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.textFieldHeader.value))
      .foregroundColor(Colors.label.swiftUIColor.opacity(0.5))
  }
  
  var error: some View {
    Text(viewModel.inlineError ?? String.empty)
      .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
      .foregroundColor(Colors.error.swiftUIColor)
      .multilineTextAlignment(.center)
      .fixedSize(horizontal: false, vertical: true)
      .opacity(viewModel.inlineError.isNotNil ? 1 : 0)
  }
  
  var footer: some View {
    VStack(spacing: 16) {
      continueButton
      VStack(spacing: 12) {
        cryptoDisclosure
        estimatedFeeDescription
      }
    }
  }
  
  var continueButton: some View {
    FullSizeButton(
      title: LFLocalizable.Button.Continue.title,
      isDisable: !viewModel.isActionAllowed
    ) {
      viewModel.continueButtonTapped()
    }
  }
  
  @ViewBuilder var cryptoDisclosure: some View {
    Text(LFLocalizable.Zerohash.Disclosure.description)
      .font(Fonts.regular.swiftUIFont(size: 10))
      .foregroundColor(Colors.label.swiftUIColor.opacity(0.5))
      .fixedSize(horizontal: false, vertical: true)
  }
  
  @ViewBuilder var estimatedFeeDescription: some View {
    Text(LFLocalizable.MoveCryptoInput.Send.estimatedFee)
      .multilineTextAlignment(.center)
      .font(Fonts.regular.swiftUIFont(size: 10))
      .foregroundColor(Colors.label.swiftUIColor.opacity(0.5))
      .fixedSize(horizontal: false, vertical: true)
  }
}
