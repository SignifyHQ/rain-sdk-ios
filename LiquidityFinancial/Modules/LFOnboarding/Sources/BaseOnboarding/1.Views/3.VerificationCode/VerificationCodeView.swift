import iPhoneNumberField
import SwiftUI
import LFStyleGuide
import LFUtilities
import LFLocalizable
import LFAccessibility
import OnboardingDomain
import Services
import Factory

public struct VerificationCodeView: View {
  @InjectedObject(\.onboardingDestinationObservable) var onboardingDestinationObservable
  
  @FocusState var keyboardFocus: Bool
  @StateObject var viewModel: VerificationCodeViewModel
    
  public init(viewModel: VerificationCodeViewModel) {
    _viewModel = .init(wrappedValue: viewModel)
  }
  
  public var body: some View {
    VStack(alignment: .leading, spacing: 28) {
      headerTitle
      enterCodeTextField
      resendCodeTimer
      Spacer()
      resendCodeButton
    }
    .ignoresSafeArea(.keyboard)
    .padding(.bottom, 16)
    .padding(.top, 8)
    .padding(.horizontal, 30)
    .defaultToolBar(
      icon: .support,
      openSupportScreen: {
        viewModel.openSupportScreen()
      },
      edgeInsets: EdgeInsets(top: 0, leading: 0, bottom: 12, trailing: 0)
    )
    .background(Colors.background.swiftUIColor)
    .popup(item: $viewModel.toastMessage, style: .toast) {
      ToastView(toastMessage: $0)
    }
    .onAppear {
      viewModel.onAppear()
    }
    .navigationLink(item: $onboardingDestinationObservable.verificationCodeDestinationView) { item in
      switch item {
      case let .identityVerificationCode(destinationView):
        destinationView
      case let .recoverWallet(destinationView):
        destinationView
      }
    }
    .navigationBarBackButtonHidden(viewModel.isShowLoading)
    .track(name: String(describing: type(of: self)))
  }
}

// MARK: - View Components
private extension VerificationCodeView {
  var headerTitle: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(L10N.Common.VerificationCode.EnterCode.screenTitle)
        .foregroundColor(Colors.label.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .accessibilityIdentifier(LFAccessibility.VerificationCode.headerTitle)
      HStack(spacing: 4) {
        Text(L10N.Common.VerificationCode.SendTo.textFieldTitle("+1"))
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        iPhoneNumberField("", text: .constant(viewModel.phoneNumberWithRegionCode))
          .flagHidden(true)
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
          .disabled(true)
        Spacer()
      }
      .accessibilityIdentifier(LFAccessibility.VerificationCode.headerDescription)
    }
  }
  
  var enterCodeTextField: some View {
    TextFieldWrapper(errorValue: $viewModel.errorMessage) {
      TextField(
        L10N.Common.VerificationCode.EnterCode.textFieldPlaceholder,
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
    .accessibilityIdentifier(LFAccessibility.VerificationCode.verificationCodeTextField)
  }
  
  @ViewBuilder
  var resendCodeTimer: some View {
    if viewModel.isShowText {
      VStack {
        if viewModel.isResendButonTimerOn {
          Text(viewModel.timeString)
            .font(Fonts.bold.swiftUIFont(size: Constants.FontSize.small.value))
            .foregroundColor(Colors.error.swiftUIColor)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 30)
            .accessibilityIdentifier(LFAccessibility.VerificationCode.resendTimerText)
        }
      }
    }
  }
  
  var resendCodeButton: some View {
    FullSizeButton(
      title: L10N.Common.VerificationCode.Resend.buttonTitle,
      isDisable: viewModel.isResendButonTimerOn,
      isLoading: $viewModel.isShowLoading,
      type: .secondary
    ) {
       viewModel.performGetOTP()
    }
    .accessibilityIdentifier(LFAccessibility.VerificationCode.resendButton)
  }
}
