import iPhoneNumberField
import SwiftUI
import LFStyleGuide
import LFUtilities
import LFLocalizable
import OnboardingDomain

struct VerificationCodeView: View {
  @StateObject private var viewModel: VerificationCodeViewModel
  @FocusState private var keyboardFocus: Bool
    
  init(
    phoneNumber: String,
    requestOTPUseCase: RequestOTPUseCaseProtocol,
    loginUseCase: LoginUseCaseProtocol
  ) {
    _viewModel = .init(
      wrappedValue: VerificationCodeViewModel(
        phoneNumber: phoneNumber,
        requestOtpUserCase: requestOTPUseCase,
        loginUserCase: loginUseCase
      )
    )
  }
  
  var body: some View {
    VStack(alignment: .leading, spacing: 28) {
      headerTitle
      enterCodeTextField
      resendCodeTimer
      Spacer()
      resendCodeButton
    }
    .ignoresSafeArea(.keyboard)
    .padding(.bottom, 16)
    .padding(.top, 30)
    .padding(.horizontal, 30)
    .toolbar {
      ToolbarItem(placement: .navigationBarTrailing) {
        Button {
          viewModel.openIntercom()
        } label: {
          GenImages.CommonImages.icChat.swiftUIImage
            .foregroundColor(Colors.label.swiftUIColor)
        }
      }
    }
    .background(Colors.background.swiftUIColor)
    .popup(item: $viewModel.toastMessage, style: .toast) {
      ToastView(toastMessage: $0)
    }
    .onChange(of: viewModel.otpCode) { _ in
      viewModel.onChangedOTPCode()
    }
    .onAppear {
      viewModel.isResendButonTimerOn = false
      Task {
        // Delay the task by 1 second:
        try await Task.sleep(nanoseconds: 1_000_000_000)
        viewModel.performAutoGetTwilioMessagesIfNeccessary()
      }
    }
    // TODO: Will be implemented later
    // .track(name: String(describing: type(of: self)))
    .navigationLink(isActive: $viewModel.isNavigationToWelcome) {
      WelcomeView()
    }
  }
}

// MARK: - View Components
private extension VerificationCodeView {
  var headerTitle: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(LFLocalizable.VerificationCode.EnterCode.screenTitle)
        .foregroundColor(Colors.label.swiftUIColor)
        .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.main.value))
      Text(
        LFLocalizable.VerificationCode.SendTo.textFieldTitle(viewModel.formatPhoneNumber)
      )
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        .font(Fonts.Inter.regular.swiftUIFont(size: Constants.FontSize.medium.value))
    }
  }
  
  var enterCodeTextField: some View {
    TextFieldWrapper(errorValue: $viewModel.errorMessage) {
      TextField(
        LFLocalizable.VerificationCode.EnterCode.textFieldPlaceholder,
        text: $viewModel.otpCode
      )
      .limitInputLength(value: $viewModel.otpCode, length: 6)
      .primaryFieldStyle()
      .disableAutocorrection(true)
      .keyboardType(.numberPad)
      .focused($keyboardFocus)
      .onAppear {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
          keyboardFocus = true
        }
      }
    }
  }
  
  @ViewBuilder var resendCodeTimer: some View {
    if viewModel.isShowText {
      VStack {
        if viewModel.isResendButonTimerOn {
          Text(viewModel.timeString)
            .font(Fonts.Inter.bold.swiftUIFont(size: Constants.FontSize.small.value))
            .foregroundColor(Colors.error.swiftUIColor)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 30)
        }
      }
    }
  }
  
  var resendCodeButton: some View {
    FullSizeButton(
      title: LFLocalizable.VerificationCode.Resend.buttonTitle,
      isDisable: viewModel.isResendButonTimerOn,
      isLoading: $viewModel.isShowLoading,
      type: .secondary
    ) {
       viewModel.resendOTP()
    }
  }
}
