import Foundation
import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable

struct RecoveryCodeView: View {
  @StateObject private var viewModel = RecoveryCodeViewModel()
  
  init() {
  }
  
  var body: some View {
    content
      .popup(item: $viewModel.toastMessage, style: .toast) {
        ToastView(toastMessage: $0)
      }
      .popup(item: $viewModel.popup) { item in
        switch item {
        case .mfaRecovered:
          mfaRecoveredPopup
        }
      }
      .padding(.horizontal, 30)
      .padding(.vertical, 16)
      .background(Colors.background.swiftUIColor)
      .defaultToolBar(icon: .support, openSupportScreen: {
        viewModel.openSupportScreen()
      })
      .track(name: String(describing: type(of: self)))
  }
}

// MARK: - View Components
private extension RecoveryCodeView {
  var content: some View {
    VStack(alignment: .leading, spacing: 24) {
      Text(LFLocalizable.Authentication.RecoveryCode.title.uppercased())
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .foregroundColor(Colors.label.swiftUIColor)
      recoveryCodeView
      Spacer()
      FullSizeButton(
        title: LFLocalizable.Button.Continue.title,
        isDisable: viewModel.recoveryCode.trimWhitespacesAndNewlines().isEmpty,
        isLoading: $viewModel.isVerifying
      ) {
        viewModel.didContinueButtonTap()
      }
    }
  }
  
  var recoveryCodeView: some View {
    VStack(alignment: .leading, spacing: 4) {
      TextFieldWrapper {
        TextField("", text: $viewModel.recoveryCode)
          .primaryFieldStyle()
          .keyboardType(.default)
          .modifier(
            PlaceholderStyle(
              showPlaceHolder: viewModel.recoveryCode.isEmpty,
              placeholder: LFLocalizable.Authentication.RecoveryCode.enterCodePlaceholder
            )
          )
          .autocorrectionDisabled()
          .limitInputLength(
            value: $viewModel.recoveryCode,
            length: Constants.MaxCharacterLimit.recoveryCode.value
          )
      }
      if let inlineErrorMessage = viewModel.inlineErrorMessage {
        Text(inlineErrorMessage)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          .foregroundColor(Colors.error.swiftUIColor)
      }
    }
  }
  
  var mfaRecoveredPopup: some View {
    LiquidityAlert(
      title: LFLocalizable.Authentication.RecoveryCode.mfaRecovered.uppercased(),
      primary: .init(text: LFLocalizable.Button.Okay.title) {
        viewModel.hidePopup()
      }
    )
  }
}
