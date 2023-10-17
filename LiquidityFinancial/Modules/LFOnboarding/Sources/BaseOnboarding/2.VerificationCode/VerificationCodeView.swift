import iPhoneNumberField
import SwiftUI
import LFStyleGuide
import LFUtilities
import LFLocalizable
import LFAccessibility
import OnboardingDomain
import LFServices
import Factory

public struct VerificationCodeView<ViewModel: VerificationCodeViewModelProtocol>: View {
  @StateObject
  var viewModel: ViewModel
  @FocusState
  var keyboardFocus: Bool
  @Injected(\.analyticsService)
  var analyticsService
  
  @ObservedObject
  var coordinator: BaseOnboardingNavigations
  
  public init(viewModel: ViewModel, coordinator: BaseOnboardingNavigations) {
    _viewModel = .init(wrappedValue: viewModel)
    self.coordinator = coordinator
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
    .defaultToolBar(icon: .support, openSupportScreen: {
      viewModel.openSupportScreen()
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
      analyticsService.track(event: AnalyticsEvent(name: .phoneVerified))
    }
    .navigationLink(item: $coordinator.verificationDestinationView) { item in
      switch item {
      case let .identityVerificationCode(destinationView):
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
      Text(LFLocalizable.VerificationCode.EnterCode.screenTitle)
        .foregroundColor(Colors.label.swiftUIColor)
        .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.main.value))
        .accessibilityIdentifier(LFAccessibility.VerificationCode.headerTitle)
      HStack(spacing: 4) {
        Text(LFLocalizable.VerificationCode.SendTo.textFieldTitle("+1"))
          .foregroundColor(Colors.label.swiftUIColor.opacity(0.75))
          .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.medium.value))
        iPhoneNumberField("", text: $viewModel.formatPhoneNumber)
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
    .accessibilityIdentifier(LFAccessibility.VerificationCode.verificationCodeTextField)
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
            .accessibilityIdentifier(LFAccessibility.VerificationCode.resendTimerText)
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
    .accessibilityIdentifier(LFAccessibility.VerificationCode.resendButton)
  }
}
