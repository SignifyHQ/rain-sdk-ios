import SwiftUI
import LFStyleGuide
import LFUtilities
import LFLocalizable

public struct VerifyEmailView: View {
  @Environment(\.dismiss)
  var dismiss
  
  @StateObject
  private var viewModel = VerifyEmailViewModel()
  
  @State
  private var viewDidLoad: Bool = false
  
  public var body: some View {
    content
      .background(Colors.background.swiftUIColor)
      .navigationBarBackButtonHidden(viewModel.isLoading)
      .defaultToolBar(
        icon: .support,
        openSupportScreen: {
          viewModel.openSupportScreen()
        }
      )
      .popup(
        item: $viewModel.toastMessage,
        style: .toast
      ) {
        ToastView(toastMessage: $0)
      }
      .onAppear(
        perform: {
          if !viewDidLoad {
            viewDidLoad = true
            viewModel.requestOTP()
          }
        }
      )
      .adaptToKeyboard()
      .ignoresSafeArea(edges: .bottom)
      .track(name: String(describing: type(of: self)))
  }
}

// MARK: - View Components
private extension VerifyEmailView {
  var content: some View {
    VStack(alignment: .center, spacing: 50) {
      topView
      middleView
      
      Spacer()
      
      FullSizeButton(
        title: LFLocalizable.Button.Continue.title,
        isDisable: !viewModel.isOTPCodeEntered,
        isLoading: $viewModel.isLoading
      ) {
        hideKeyboard()
        viewModel.didTapContinueButton {
          dismiss()
        }
      }
    }
    .padding([.horizontal, .bottom], 30)
  }
  
  var topView: some View {
    VStack(spacing: 12) {
      Text(LFLocalizable.Authentication.VerifyEmail.title)
        .foregroundColor(Colors.label.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
      Text(LFLocalizable.Authentication.VerifyEmail.description)
        .multilineTextAlignment(.center)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        .foregroundColor(Colors.label.swiftUIColor)
    }
    .padding(.top, 16)
  }
  
  var middleView: some View {
    VStack {
      PinCodeView(
        code: $viewModel.generatedOTP,
        isDisabled: $viewModel.isLoading,
        codeLength: viewModel.otpCodeLength
      )
      resendCodeButton
        .padding(.top)
    }
  }
  
  var resendCodeButton: some View {
    Button {
      viewModel.didTapResendCodeButton()
    } label: {
      Text(LFLocalizable.Authentication.ResetPassword.ResendCodeButton.title)
        .foregroundColor(Colors.primary.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
    }
    .disabled(viewModel.isLoading)
  }
}
