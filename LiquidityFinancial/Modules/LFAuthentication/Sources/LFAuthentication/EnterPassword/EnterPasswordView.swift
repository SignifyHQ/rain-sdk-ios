import Foundation
import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable

public struct EnterPasswordView: View {
  @StateObject
  private var viewModel: EnterPasswordViewModel
  @FocusState
  private var isFocused: Bool
  
  @Binding var isFlowPresented: Bool
  
  public init(
    purpose: EnterPasswordPurpose,
    isFlowPresented: Binding<Bool>
  ) {
    _viewModel = .init(wrappedValue: EnterPasswordViewModel(purpose: purpose))
    _isFlowPresented = .init(projectedValue: isFlowPresented)
  }
  
  public var body: some View {
    VStack {
      topView
      
      wrongPasswordErrorMessage
      
      Spacer()
      buttonGroupView
    }
    .padding(.horizontal, 30)
    .padding(.bottom, 16)
    .background(Colors.background.swiftUIColor)
    .defaultToolBar(icon: .support, openSupportScreen: {
      viewModel.openSupportScreen()
    })
    .navigationBarBackButtonHidden(viewModel.isLoading)
    .popup(item: $viewModel.toastMessage, style: .toast) {
      ToastView(toastMessage: $0)
    }
    .navigationLink(
      item: $viewModel.navigation
    ) { navigation in
      switch navigation {
      case .recoverPassword:
        ResetPasswordView(isFlowPresented: $isFlowPresented)
      case .changePassword:
        CreatePasswordView(purpose: .changePassword) {
          isFlowPresented = false
        }
      }
    }
    .onChange(
      of: viewModel.shouldDismissFlow
    ) { _ in
      isFlowPresented = false
    }
    .track(name: String(describing: type(of: self)))
  }
}

// MARK: - View Components
private extension EnterPasswordView {
  var topView: some View {
    VStack(alignment: .leading, spacing: 24) {
      Text(viewModel.purpose == .changePassword ? LFLocalizable.Authentication.ChangePassword.title : LFLocalizable.Authentication.EnterPassword.title.uppercased())
        .foregroundColor(Colors.label.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
      
      enterPasswordTextFieldView
    }
  }
  
  var enterPasswordTextFieldView: some View {
    VStack(alignment: .leading) {
      if viewModel.purpose == .changePassword {
        Text(LFLocalizable.Authentication.ChangePassword.Current.title)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.textFieldHeader.value))
          .foregroundColor(Colors.label.swiftUIColor)
          .opacity(0.75)
      }
      
      TextFieldWrapper {
        SecureField("", text: $viewModel.password)
          .keyboardType(.alphabet)
          .tint(Colors.label.swiftUIColor)
          .restrictInput(value: $viewModel.password, restriction: .none)
          .modifier(
            PlaceholderStyle(
              showPlaceHolder: $viewModel.password.wrappedValue.isEmpty,
              placeholder: viewModel.purpose == .changePassword ? LFLocalizable.Authentication.ChangePassword.Current.placeholder : LFLocalizable.Authentication.EnterPassword.placeholder
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
  
  @ViewBuilder
  var wrongPasswordErrorMessage: some View {
    if let inlineError = viewModel.inlineErrorMessage {
      Text(inlineError)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.small.value))
        .foregroundColor(Colors.error.swiftUIColor)
        .frame(maxWidth: .infinity, alignment: .leading)
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
