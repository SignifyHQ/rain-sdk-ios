import Foundation
import LFUtilities
import OnboardingDomain
import OnboardingData
import Combine
import SwiftUI
import Factory
import NetspendSdk
import Services
import AccountData
import AccountDomain
import LFLocalizable
import OnboardingComponents
import EnvironmentService

@MainActor
final class VerificationCodeViewModel: ObservableObject {
  enum VerificationCodeNavigation {
    case identityVerificationCode(AnyView)
  }
  
  @LazyInjected(\.environmentService) var environmentService
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.onboardingRepository) var onboardingRepository
  @LazyInjected(\.noBankOnboardingFlowCoordinator) var onboardingFlowCoordinator
  @LazyInjected(\.customerSupportService) var customerSupportService
  @LazyInjected(\.analyticsService) var analyticsService
  
  @Published var isNavigationToWelcome: Bool = false
  @Published var isResendButonTimerOn = false
  @Published var isShowText: Bool = true
  @Published var isShowLoading: Bool = false
  @Published var formatPhoneNumber: String = ""
  @Published var otpCode: String = ""
  @Published var timeString: String = ""
  @Published var toastMessage: String?
  @Published var errorMessage: String?
  @Published var navigation: VerificationCodeNavigation?
  
  var requireAuth: [RequiredAuth]
  var cancellables: Set<AnyCancellable> = []
  lazy var requestOtpUseCase: RequestOTPUseCaseProtocol = {
    RequestOTPUseCase(repository: onboardingRepository)
  }()
  lazy var loginUseCase: LoginUseCaseProtocol = {
    LoginUseCase(repository: onboardingRepository)
  }()
  
  init(phoneNumber: String, requireAuth: [RequiredAuth]) {
    self.requireAuth = requireAuth
    formatPhoneNumber = Constants.Default.regionCode.rawValue + phoneNumber
    performAutoGetTwilioMessagesIfNeccessary()
  }
}

  // MARK: API
extension VerificationCodeViewModel {
  func handleAfterGetOTP() {
    guard !isShowLoading else { return }
    isShowLoading = true
    if requireAuth.count == 1 && requireAuth.contains(where: { $0 == .otp }) {
      analyticsService.track(event: AnalyticsEvent(name: .viewSignUpLogin))
      performVerifyOTPCode()
    } else {
      isShowLoading = false
      let isSSNCheck = requireAuth.contains(where: { $0 == .ssn })
      let isPassportCheck = requireAuth.contains(where: { $0 == .passport })
      let identityVerificationKind: IdentityVerificationCodeKind? = isSSNCheck
      ? .ssn
      : isPassportCheck ? .passport : nil
      if let kind = identityVerificationKind {
        let viewModel = IdentityVerificationCodeViewModel(phoneNumber: formatPhoneNumber, otpCode: otpCode, kind: kind)
        let view = IdentityVerificationCodeView(viewModel: viewModel)
        let delayTime = environmentService.networkEnvironment == .productionTest ? 0.5 : 0

        // Make sure we don't navigate immediately when the parent view has just appeared
        DispatchQueue.main.asyncAfter(deadline: .now() + delayTime) {
          self.navigation = .identityVerificationCode(AnyView(view))
        }
      }
    }
  }
  
  func performVerifyOTPCode() {
    Task {
    #if DEBUG
      let start = CFAbsoluteTimeGetCurrent()
    #endif
      do {
        let parameters = LoginParameters(phoneNumber: formatPhoneNumber, otpCode: otpCode)

        // All crypto apps are still using the old authentication flow. The new authentication flow will be applied later.
        _ = try await loginUseCase.execute(isNewAuth: false, parameters: parameters)
        accountDataManager.update(phone: formatPhoneNumber)
        accountDataManager.stored(phone: formatPhoneNumber)
        
        await checkOnboardingState()
        
        analyticsService.set(params: ["phoneVerified": true])
        analyticsService.track(event: AnalyticsEvent(name: .loggedIn))
        
        self.isShowLoading = false
        
      } catch {
        analyticsService.set(params: ["phoneVerified": false])
        analyticsService.track(event: AnalyticsEvent(name: .phoneVerificationError))
        handleError(error: error)
      }
    #if DEBUG
      let diff = CFAbsoluteTimeGetCurrent() - start
      log.debug("Took \(diff) seconds")
    #endif
    }
  }
  
  func performGetOTP() {
    Task {
      defer { isShowLoading = false }
      isShowLoading = true
      do {
        let parameters = OTPParameters(phoneNumber: formatPhoneNumber)
        
        // All crypto apps are still using the old authentication flow. The new authentication flow will be applied later.
        _ = try await requestOtpUseCase.execute(isNewAuth: false, parameters: parameters)
        
        isShowLoading = false
      } catch {
        isShowLoading = false
        toastMessage = error.userFriendlyMessage
      }
    }
  }
  
  func performAutoGetTwilioMessagesIfNeccessary() {
    guard environmentService.networkEnvironment == .productionTest else { return }
    DemoAccountsHelper.shared.getOTPInternal(for: formatPhoneNumber)
      .removeDuplicates()
      .receive(on: DispatchQueue.main)
      .delay(for: 1, scheduler: RunLoop.main)
      .sink { [weak self] code in
        guard let self else { return }
        log.debug(code ?? "performGetTwilioMessagesIfNeccessary not found")
        guard let code else { return }
        self.otpCode = code
      }
      .store(in: &cancellables)
  }
  
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }
}

  // MARK: View Helpers
extension VerificationCodeViewModel {
  func onChangedOTPCode() {
    if otpCode.count == Constants.MaxCharacterLimit.verificationLimit.value {
      handleAfterGetOTP()
    }
  }
  
  func resendOTP() {
    performGetOTP()
  }
  
  func handleError(error: Error) {
    isShowLoading = false
    guard let code = error.asErrorObject?.code else {
      toastMessage = error.userFriendlyMessage
      return
    }
    switch code {
    case Constants.ErrorCode.userInactive.value:
      onboardingFlowCoordinator.set(route: .accountLocked)
    case Constants.ErrorCode.credentialsInvalid.value:
      toastMessage = L10N.Common.VerificationCode.OtpInvalid.message
    default:
      toastMessage = error.userFriendlyMessage
    }
  }
}

  // MARK: Private Functions
private extension VerificationCodeViewModel {
  
  @MainActor
  func checkOnboardingState() async {
    await onboardingFlowCoordinator.apiFetchCurrentState()
  }
}
