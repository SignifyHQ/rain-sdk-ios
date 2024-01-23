import Foundation
import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable

public struct EnterPasswordView: View {
  @StateObject
  private var viewModel: EnterPasswordViewModel
  @FocusState
  private var isSecureFieldFocused: Bool?
  @State
  private var isInputSecured: Bool = true
  
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
      case let .recoverPassword(purpose):
        ResetPasswordView(purpose: purpose) {
          switch purpose {
          case .resetPassword:
            isFlowPresented = false
          case .login:
            viewModel.navigation = nil
          }
        }
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
  
  private func toggleSecuredInput() {
    isInputSecured.toggle()
    isSecureFieldFocused = isInputSecured
  }
}

// MARK: - View Components
private extension EnterPasswordView {
  var topView: some View {
    VStack(alignment: .leading, spacing: 24) {
      Text(viewModel.purpose == .changePassword ? L10N.Common.Authentication.ChangePassword.title : L10N.Common.Authentication.EnterPassword.title.uppercased())
        .foregroundColor(Colors.label.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
      
      enterPasswordTextFieldView
    }
  }
  
  var enterPasswordTextFieldView: some View {
    VStack(alignment: .leading) {
      if viewModel.purpose == .changePassword {
        Text(L10N.Common.Authentication.ChangePassword.Current.title)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.textFieldHeader.value))
          .foregroundColor(Colors.label.swiftUIColor)
          .opacity(0.75)
      }
      
      TextFieldWrapper {
        HStack {
          Group {
            SecureField("", text: $viewModel.password)
              .focused($isSecureFieldFocused, equals: true)
              .isHidden(hidden: !isInputSecured)
            
            TextField("", text: $viewModel.password)
              .focused($isSecureFieldFocused, equals: false)
              .isHidden(hidden: isInputSecured)
          }
          .keyboardType(.alphabet)
          .tint(Colors.label.swiftUIColor)
          .restrictInput(value: $viewModel.password, restriction: .none)
          .modifier(
            PlaceholderStyle(
              showPlaceHolder: $viewModel.password.wrappedValue.isEmpty,
              placeholder: viewModel.purpose == .changePassword ? L10N.Common.Authentication.ChangePassword.Current.placeholder : L10N.Common.Authentication.EnterPassword.placeholder
            )
          )
          .primaryFieldStyle()
          .autocapitalization(.none)
          .autocorrectionDisabled()
          .limitInputLength(
            value: $viewModel.password,
            length: Constants.MaxCharacterLimit.password.value
          )
          
          Spacer()
          
          Button {
            toggleSecuredInput()
          } label: {
            showHideImage
              .swiftUIImage
              .foregroundColor(Colors.label.swiftUIColor)
          }
        }
      }
      .disabled(viewModel.isLoading)
      .onAppear {
        isSecureFieldFocused = isInputSecured
      }
    }
  }
  
  private var showHideImage: ImageAsset {
    isInputSecured ? GenImages.CommonImages.icPasswordShow : GenImages.CommonImages.icPasswordHide
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
        Text(L10N.Common.Authentication.EnterPassword.forgotPasswordButton)
          .foregroundColor(Colors.primary.swiftUIColor)
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
      }
      .disabled(viewModel.isLoading)
      
      FullSizeButton(
        title: L10N.Common.Button.Continue.title,
        isDisable: viewModel.isDisableContinueButton,
        isLoading: $viewModel.isLoading,
        type: .primary
      ) {
        viewModel.didTapContinueButton()
      }
    }
  }
}
