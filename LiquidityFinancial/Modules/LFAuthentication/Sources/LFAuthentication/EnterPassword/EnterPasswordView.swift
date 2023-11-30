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
  
  public init() {}
  
  public var body: some View {
    VStack {
      enterPasswordTextFieldView
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
      .onAppear {
        isFocused = true
      }
    }
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
      FullSizeButton(
        title: LFLocalizable.Button.Continue.title,
        isDisable: viewModel.isDisableContinueButton,
        isLoading: $viewModel.isVerifyingPassword,
        type: .primary
      ) {
        viewModel.didTapContinueButton()
      }
    }
  }
}
