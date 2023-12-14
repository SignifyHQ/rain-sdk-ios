import Foundation
import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable

public struct EnterPasswordView: View {
  @StateObject
  private var viewModel = EnterPasswordViewModel()
  @FocusState
  private var isFocused: Bool
  
  @Binding var shouldDismissRoot: Bool
  
  public var body: some View {
    VStack {
      enterPasswordTextFieldView
      
      if viewModel.isInlineErrorShown {
        wrongPasswordErrorMessage
      }
      
      Spacer()
      buttonGroupView
    }
    .padding(.horizontal, 30)
    .padding(.bottom, 16)
    .background(Colors.background.swiftUIColor)
    .defaultToolBar(icon: .support, openSupportScreen: {
      viewModel.openSupportScreen()
    })
    .popup(item: $viewModel.toastMessage, style: .toast) {
      ToastView(toastMessage: $0)
    }
    .navigationLink(item: $viewModel.navigation) { navigation in
      switch navigation {
      case .recoverPassword:
        ResetPasswordView(shouldDismissRoot: $shouldDismissRoot)
      }
    }
    .track(name: String(describing: type(of: self)))
  }
}

// MARK: - View Components
private extension EnterPasswordView {
  var enterPasswordTextFieldView: some View {
    VStack(alignment: .leading, spacing: 24) {
      Text(LFLocalizable.Authentication.EnterPassword.title.uppercased())
        .foregroundColor(Colors.label.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
      TextFieldWrapper {
        SecureField("", text: $viewModel.password)
          .keyboardType(.alphabet)
          .tint(Colors.label.swiftUIColor)
          .restrictInput(value: $viewModel.password, restriction: .none)
          .modifier(
            PlaceholderStyle(
              showPlaceHolder: $viewModel.password.wrappedValue.isEmpty,
              placeholder: LFLocalizable.Authentication.EnterPassword.placeholder
            )
          )
          .primaryFieldStyle()
          .autocapitalization(.none)
          .autocorrectionDisabled()
          .limitInputLength(
            value: $viewModel.password,
            length: Constants.MaxCharacterLimit.password.value
          )
          .focused($isFocused)
      }
      .disabled(viewModel.isLoading)
      .onAppear {
        isFocused = true
      }
    }
  }
  
  var wrongPasswordErrorMessage: some View {
    Text(LFLocalizable.Authentication.EnterPassword.Error.wrongPassword)
      .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
      .foregroundColor(Colors.error.swiftUIColor)
      .frame(maxWidth: .infinity, alignment: .leading)
  }
  
  var buttonGroupView: some View {
    VStack(spacing: 32) {
      Button {
        viewModel.didTapForgotPasswordButton()
      } label: {
        Text(LFLocalizable.Authentication.EnterPassword.forgotPasswordButton)
          .foregroundColor(Colors.primary.swiftUIColor)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
      }
      .disabled(viewModel.isLoading)
      
      FullSizeButton(
        title: LFLocalizable.Button.Continue.title,
        isDisable: viewModel.isDisableContinueButton,
        isLoading: $viewModel.isLoading,
        type: .primary
      ) {
        viewModel.didTapContinueButton()
      }
    }
  }
}
