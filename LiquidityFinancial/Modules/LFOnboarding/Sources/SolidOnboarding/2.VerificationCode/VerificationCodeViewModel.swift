import Foundation
import LFUtilities
import OnboardingDomain
import OnboardingData
import Combine
import SwiftUI
import Factory
import Services
import AccountData
import AccountDomain
import LFLocalizable
import UIComponents
import SolidData
import SolidDomain
import EnvironmentService
import LFAuthentication
import LFFeatureFlags

@MainActor
final class VerificationCodeViewModel: ObservableObject {
  enum VerificationCodeNavigation {
    case identityVerificationCode(AnyView)
  }
  
  @LazyInjected(\.environmentService) var environmentService
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.onboardingRepository) var onboardingRepository
  @LazyInjected(\.solidOnboardingFlowCoordinator) var solidOnboardingFlowCoordinator
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
    
    guard requireAuth.contains(.otp), requireAuth.count == 1 else {
      if let kind = requireAuth.first(where: { $0 != .otp }) {
        handleNewDeviceVerification(kind: kind)
      }
      return
    }
    
    analyticsService.track(event: AnalyticsEvent(name: .viewSignUpLogin))
    performVerifyOTPCode()
  }
  
  func performVerifyOTPCode() {
    Task {
    #if DEBUG
      let start = CFAbsoluteTimeGetCurrent()
    #endif
      do {
        let parameters = LoginParameters(
          phoneNumber: formatPhoneNumber,
          otpCode: otpCode
        )
        _ = try await loginUseCase.execute(
          isNewAuth: LFFeatureFlagContainer.isMultiFactorAuthFeatureFlagEnabled,
          parameters: parameters
        )
        
        self.handleLoginSuccess {
          self.isShowLoading = false
        }
        
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
        _ = try await requestOtpUseCase.execute(
          isNewAuth: LFFeatureFlagContainer.isMultiFactorAuthFeatureFlagEnabled,
          parameters: parameters
        )
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
      .sink { [weak self] code in
        guard let self else { return }
        log.debug("OTPInternal :\(code ?? "performGetTwilioMessagesIfNeccessary not found")")
        guard let code else { return }
        self.otpCode = code
        self.handleAfterGetOTP()
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
      solidOnboardingFlowCoordinator.set(route: .accountLocked)
    case Constants.ErrorCode.credentialsInvalid.value:
      toastMessage = L10N.Common.VerificationCode.OtpInvalid.message
    default:
      toastMessage = error.userFriendlyMessage
    }
  }
}

  // MARK: Private Functions
private extension VerificationCodeViewModel {
  func handleNewDeviceVerification(kind: RequiredAuth) {
    isShowLoading = false
    
    switch kind {
    case .mfa:
      handleMFAVerification()
    case .password:
      handlePasswordVerification()
    case .ssn:
      handleIdentifyVerification(kind: .ssn)
    case .passport:
      handleIdentifyVerification(kind: .passport)
    default:
      break
    }
  }
  
  func handleMFAVerification() {
    let parameters = LoginParameters(
      phoneNumber: formatPhoneNumber,
      otpCode: otpCode,
      verification: Verification(type: VerificationType.totp.rawValue, secret: .empty)
    )
    let purpose = EnterTOTPCodePurpose.login(parameters: parameters, fallbackType: VerificationType.recoveryCode.rawValue) {
      self.handleLoginSuccess()
    }
    let view = EnterTOTPCodeView(purpose: purpose, isFlowPresented: .constant(false))
    
    navigation = .identityVerificationCode(AnyView(view))
  }
  
  func handlePasswordVerification() {
    let parameters = LoginParameters(
      phoneNumber: formatPhoneNumber,
      otpCode: otpCode,
      verification: Verification(type: VerificationType.password.rawValue, secret: .empty)
    )
    let purpose = EnterPasswordPurpose.login(parameters: parameters) {
      self.handleLoginSuccess()
    }
    let view = EnterPasswordView(purpose: purpose, isFlowPresented: .constant(false))
    
    navigation = .identityVerificationCode(AnyView(view))
  }
  
  func handleIdentifyVerification(kind: IdentityVerificationCodeKind) {
    let viewModel = IdentityVerificationCodeViewModel(phoneNumber: formatPhoneNumber, otpCode: otpCode, kind: kind)
    let view = IdentityVerificationCodeView(viewModel: viewModel)
    navigation = .identityVerificationCode(AnyView(view))
  }
  
  func handleLoginSuccess(onCompletion: (() -> Void)? = nil) {
    accountDataManager.update(phone: formatPhoneNumber)
    accountDataManager.stored(phone: formatPhoneNumber)
    
    Task {
      defer {
        NotificationCenter.default.post(name: .didLoginComplete, object: nil)
        onCompletion?()
      }
      
      do {
        try await solidOnboardingFlowCoordinator.handlerOnboardingStep()
        
        analyticsService.set(params: ["phoneVerified": true])
        analyticsService.track(event: AnalyticsEvent(name: .loggedIn))
      } catch {
        log.error(error.localizedDescription)
        
        analyticsService.set(params: ["phoneVerified": false])
        analyticsService.track(event: AnalyticsEvent(name: .phoneVerificationError))
        solidOnboardingFlowCoordinator.forcedLogout()
      }
    }
  }
}
