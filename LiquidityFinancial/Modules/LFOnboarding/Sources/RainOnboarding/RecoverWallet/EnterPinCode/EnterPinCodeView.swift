import SwiftUI
import LFLocalizable
import LFUtilities
import LFStyleGuide
import AccountData
import Services

struct EnterPinCodeView: View {
  @StateObject private var viewModel: EnterPinCodeViewModel
  
  init() {
    _viewModel = .init(
      wrappedValue: EnterPinCodeViewModel()
    )
  }
  
  var body: some View {
    VStack(alignment: .leading, spacing: 24) {
      headerTitle
      pinCodeView
      Spacer()
      bottomButtonView
    }
    .padding(30)
    .background(Colors.background.swiftUIColor)
    .popup(item: $viewModel.popup) { item in
      switch item {
      case .recoverySuccessfully:
        recoverySuccessfullyPopup
      }
    }
    .navigationBarTitleDisplayMode(.inline)
    .track(name: String(describing: type(of: self)))
  }
}

// MARK: View Components
private extension EnterPinCodeView {
  var headerTitle: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(L10N.Common.EnterPinCode.title.uppercased())
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .foregroundColor(Colors.label.swiftUIColor)
      Text(L10N.Common.EnterPinCode.description)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
    }
  }
  
  var pinCodeView: some View {
    VStack(spacing: 24) {
      PinCodeView(
        code: $viewModel.pinCode,
        isDisabled: $viewModel.isLoading,
        codeLength: viewModel.pinCodeLength
      )
      if let errorMessage = viewModel.inlineMessage {
        Text(errorMessage)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          .foregroundColor(Colors.error.swiftUIColor)
      }
    }
    .padding(.top, 80)
    .padding(.horizontal, 24)
  }
  
  var bottomButtonView: some View {
    FullSizeButton(
      title: L10N.Common.Button.Continue.title,
      isDisable: viewModel.isButtonDisable,
      isLoading: $viewModel.isLoading
    ) {
      viewModel.recoverWalletByPassword()
    }
    .ignoresSafeArea(.keyboard, edges: .bottom)
  }
  
  var recoverySuccessfullyPopup: some View {
    LiquidityAlert(
      title:  L10N.Common.RecoveryComplete.title.uppercased(),
      message: L10N.Common.RecoveryComplete.message,
      primary: .init(text: L10N.Common.Button.Ok.title) {
        viewModel.recoverySuccessfullyPrimaryButtonTapped()
      }
    )
  }
}
