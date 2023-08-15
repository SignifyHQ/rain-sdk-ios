import iPhoneNumberField
import SwiftUI
import LFStyleGuide
import LFUtilities
import LFLocalizable
import OnboardingDomain
import NetSpendData
import DogeOnboarding

struct VerificationCodeView: View {
  @StateObject private var viewModel: VerificationCodeViewModel
  @FocusState private var keyboardFocus: Bool
    
  init(phoneNumber: String) {
    _viewModel = .init(wrappedValue: VerificationCodeViewModel(phoneNumber: phoneNumber))
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
    .defaultToolBar(icon: .intercom, openIntercom: {
      viewModel.openIntercom()
    })
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
        try await Task.sleep(seconds: 0.1)
        viewModel.performAutoGetTwilioMessagesIfNeccessary()
      }
    }
    // TODO: Will be implemented later
    // .track(name: String(describing: type(of: self)))
    .navigationBarBackButtonHidden(viewModel.isShowLoading)
  }
}

// MARK: - View Components
private extension VerificationCodeView {
  var headerTitle: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(LFLocalizable.VerificationCode.EnterCode.screenTitle)
        .foregroundColor(Colors.label.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
      HStack(spacing: 4) {
        Text(
          LFLocalizable.VerificationCode.SendTo.textFieldTitle("+1")
        )
        .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        iPhoneNumberField("", text: $viewModel.formatPhoneNumber)
          .flagHidden(true)
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
          .disabled(true)
        Spacer()
      }
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
            .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.small.value))
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

#if DEBUG
struct VerificationCodeView_Previews: PreviewProvider {
  static var previews: some View {
    VerificationCodeView(phoneNumber: "2345678888")
      .previewLayout(PreviewLayout.sizeThatFits)
      .previewDisplayName("Default preview")
  }
}
#endif
