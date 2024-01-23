import Foundation
import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable

struct RecoveryCodeView: View {
  @StateObject private var viewModel: RecoveryCodeViewModel
  @FocusState var isTextFieldInFocus: Bool
  
  init(purpose: RecoveryCodePurpose) {
    _viewModel = .init(
      wrappedValue: RecoveryCodeViewModel(purpose: purpose)
    )
  }
  
  var body: some View {
    content
      .popup(
        item: $viewModel.toastMessage,
        style: .toast
      ) {
        ToastView(toastMessage: $0)
      }
      .popup(
        item: $viewModel.popup,
        dismissAction: viewModel.dismissAction
      ) { item in
        switch item {
        case .mfaTurnedOff:
          mfaDisabledPopup
        }
      }
      .padding(.horizontal, 30)
      .padding(.vertical, 16)
      .background(Colors.background.swiftUIColor)
      .defaultToolBar(
        icon: .support,
        openSupportScreen: {
          viewModel.openSupportScreen()
        }
      )
      .navigationBarBackButtonHidden(viewModel.isVerifying)
      .track(name: String(describing: type(of: self)))
  }
}

// MARK: - View Components
private extension RecoveryCodeView {
  var content: some View {
    VStack(alignment: .leading, spacing: 24) {
      Text(L10N.Common.Authentication.RecoveryCode.title.uppercased())
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .foregroundColor(Colors.label.swiftUIColor)
      
      recoveryCodeView
      
      Spacer()
      
      FullSizeButton(
        title: L10N.Common.Button.Continue.title,
        isDisable: viewModel.recoveryCode.trimWhitespacesAndNewlines().isEmpty,
        isLoading: $viewModel.isVerifying
      ) {
        isTextFieldInFocus = false
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
              placeholder: L10N.Common.Authentication.RecoveryCode.enterCodePlaceholder
            )
          )
          .autocorrectionDisabled()
          .limitInputLength(
            value: $viewModel.recoveryCode,
            length: Constants.MaxCharacterLimit.recoveryCode.value
          )
      }
      .focused($isTextFieldInFocus)
      .disabled(viewModel.isVerifying)
      
      if let inlineErrorMessage = viewModel.inlineErrorMessage {
        Text(inlineErrorMessage)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
          .foregroundColor(Colors.error.swiftUIColor)
      }
    }
  }
  
  var mfaDisabledPopup: some View {
    LiquidityAlert(
      title: L10N.Common.Authentication.EnterTotp.mfaTurnedOff.uppercased(),
      primary: .init(text: L10N.Common.Button.Okay.title) {
        viewModel.dismissAction()
      }
    )
  }
}
