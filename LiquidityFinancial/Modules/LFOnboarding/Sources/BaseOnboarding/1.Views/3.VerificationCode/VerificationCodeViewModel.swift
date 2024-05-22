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
import PortalData
import PortalDomain
import LFLocalizable
import LFFeatureFlags
import EnvironmentService
import LFAuthentication

// MARK: - VerificationCodeNavigation
public enum VerificationCodeNavigation {
  case identityVerificationCode(AnyView)
}

// MARK: - VerificationCodeViewModel
@MainActor
public final class VerificationCodeViewModel: ObservableObject {
  @InjectedObject(\.onboardingDestinationObservable) var onboardingDestinationObservable
  
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.featureFlagManager) var featureFlagManager
  @LazyInjected(\.onboardingRepository) var onboardingRepository
  @LazyInjected(\.customerSupportService) var customerSupportService
  @LazyInjected(\.portalRepository) var portalRepository
  @LazyInjected(\.analyticsService) var analyticsService
  @LazyInjected(\.environmentService) var environmentService
  @LazyInjected(\.portalService) var portalService

  @Published var isNavigationToWelcome: Bool = false
  @Published var isResendButonTimerOn = false
  @Published var isShowText: Bool = true
  @Published var isShowLoading: Bool = false
  @Published var otpCode: String = ""
  @Published var timeString: String = ""
  @Published var toastMessage: String?
  @Published var errorMessage: String?
  
  let phoneNumberWithRegionCode: String
  
  lazy var requestOtpUseCase: RequestOTPUseCaseProtocol = {
    RequestOTPUseCase(repository: onboardingRepository)
  }()
  
  lazy var loginUseCase: LoginUseCaseProtocol = {
    LoginUseCase(repository: onboardingRepository)
  }()
  
  lazy var registerPortalUseCase: RegisterPortalUseCaseProtocol = {
    RegisterPortalUseCase(repository: portalRepository)
  }()
  
  private var requireAuth: [RequiredAuth]
  private var cancellables: Set<AnyCancellable> = []
  
  private let handleOnboardingStep: (() async throws -> Void)?
  private let forceLogout: (() -> Void)?
  private let setRouteToAccountLocked: (() -> Void)?

  public init(
    phoneNumber: String,
    requireAuth: [RequiredAuth],
    handleOnboardingStep: (() async throws -> Void)?,
    forceLogout: (() -> Void)?,
    setRouteToAccountLocked: (() -> Void)?
  ) {
    self.requireAuth = requireAuth
    self.handleOnboardingStep = handleOnboardingStep
    self.forceLogout = forceLogout
    self.setRouteToAccountLocked = setRouteToAccountLocked
    
    phoneNumberWithRegionCode = Constants.Default.regionCode.rawValue + phoneNumber
    observePasswordInput()
    performAutoGetOTPFromTwilioIfNeccessary()
  }
}

  // MARK: - APIs Handler
extension VerificationCodeViewModel {
  func performGetOTP() {
    Task {
      defer { isShowLoading = false }
      isShowLoading = true
      
      do {
        /*
         All cryptocurrency applications are currently utilizing the old authentication flow.
         The implementation of the new authentication flow will be postponed until a later time.
         */
        let isNewAuth = LFUtilities.cryptoEnabled ? false : featureFlagManager.isFeatureFlagEnabled(.mfa)
        let parameters = OTPParameters(phoneNumber: phoneNumberWithRegionCode)
        _ = try await requestOtpUseCase.execute(
          isNewAuth: isNewAuth,
          parameters: parameters
        )
      } catch {
        toastMessage = error.userFriendlyMessage
      }
    }
  }
  
  func performVerifyOTPCode() {
    Task {
      do {
        /*
         All cryptocurrency applications are currently utilizing the old authentication flow.
         The implementation of the new authentication flow will be postponed until a later time.
         */
        let parameters = LoginParameters(
          phoneNumber: phoneNumberWithRegionCode,
          otpCode: otpCode
        )
        let isNewAuth = LFUtilities.cryptoEnabled ? false : featureFlagManager.isFeatureFlagEnabled(.mfa)
        
        let response = try await loginUseCase.execute(
          isNewAuth: isNewAuth,
          parameters: parameters
        )
        
        await setupPortal(portalToken: response.portalSessionToken)
        
        handleLoginSuccess {
          self.isShowLoading = false
        }
      } catch {
        analyticsLoginEvent(isSuccess: false, eventName: .phoneVerificationError)
        handleError(error: error)
      }
    }
  }
  
  func handleLoginSuccess(onCompletion: (() -> Void)? = nil) {
    accountDataManager.update(phone: phoneNumberWithRegionCode)
    accountDataManager.stored(phone: phoneNumberWithRegionCode)
    
    Task {
      defer {
        NotificationCenter.default.post(name: .didLoginComplete, object: nil)
        onCompletion?()
      }
      
      do {
        try await handleOnboardingStep?()
        
        analyticsLoginEvent(isSuccess: true, eventName: .loggedIn)
      } catch {
        log.error(error.localizedDescription)
        analyticsLoginEvent(isSuccess: false, eventName: .phoneVerificationError)
        forceLogout?()
      }
    }
  }
}

  // MARK: View Handler
extension VerificationCodeViewModel {
  func onAppear() {
    isResendButonTimerOn = false
    analyticsService.track(event: AnalyticsEvent(name: .phoneVerified))
  }
  
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }
}

// MARK: - Private Functions
private extension VerificationCodeViewModel {
  func handleAfterGetOTP() {
    guard !isShowLoading else { return }
    isShowLoading = true
    
    let isOldDevice = requireAuth.count == 1 && requireAuth.contains(.otp)
    guard isOldDevice else {
      if let kind = requireAuth.first(where: { $0 != .otp }) {
        handleNewDeviceVerification(kind: kind)
      }
      return
    }
    
    analyticsService.track(event: AnalyticsEvent(name: .viewSignUpLogin))
    performVerifyOTPCode()
  }
  
  func performAutoGetOTPFromTwilioIfNeccessary() {
    guard environmentService.networkEnvironment == .productionTest else {
      return
    }
    
    DemoAccountsHelper.shared.getOTPInternal(for: phoneNumberWithRegionCode)
      .removeDuplicates()
      .receive(on: DispatchQueue.main)
      .sink { [weak self] code in
        log.debug(code ?? "performGetTwilioMessagesIfNeccessary not found")
        guard let self, let code else { return }
        
        self.otpCode = code
      }
      .store(in: &cancellables)
  }
  
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
  
  func observePasswordInput() {
    $otpCode
      .receive(on: DispatchQueue.main)
      .sink(
        receiveCompletion: { _ in },
        receiveValue: { [weak self] otpCode in
          let verificationCodeMaxLength = Constants.MaxCharacterLimit.verificationLimit.value
          guard let self, otpCode.count == verificationCodeMaxLength else { return }
          
          self.handleAfterGetOTP()
        }
      )
      .store(in: &cancellables)
  }
  
  func analyticsLoginEvent(isSuccess: Bool, eventName: AnalyticsEventName) {
    analyticsService.set(params: ["phoneVerified": true])
    analyticsService.track(event: AnalyticsEvent(name: eventName))
  }
  
  func handleError(error: Error) {
    isShowLoading = false
    guard let code = error.asErrorObject?.code else {
      toastMessage = error.userFriendlyMessage
      return
    }
    
    switch code {
    case Constants.ErrorCode.userInactive.value:
      setRouteToAccountLocked?()
    case Constants.ErrorCode.credentialsInvalid.value:
      toastMessage = L10N.Common.VerificationCode.OtpInvalid.message
    default:
      toastMessage = error.userFriendlyMessage
    }
  }
  
  func handleMFAVerification() {
    let parameters = LoginParameters(
      phoneNumber: phoneNumberWithRegionCode,
      otpCode: otpCode,
      verification: Verification(type: VerificationType.totp.rawValue, secret: .empty)
    )
    let purpose = EnterTOTPCodePurpose.login(parameters: parameters, fallbackType: VerificationType.recoveryCode.rawValue) {
      self.handleLoginSuccess()
    }
    let view = EnterTOTPCodeView(purpose: purpose, isFlowPresented: .constant(false))
    
    navigateToIdentityVerificationCodeScreen(view: AnyView(view))
  }
  
  func handlePasswordVerification() {
    let parameters = LoginParameters(
      phoneNumber: phoneNumberWithRegionCode,
      otpCode: otpCode,
      verification: Verification(type: VerificationType.password.rawValue, secret: .empty)
    )
    let purpose = EnterPasswordPurpose.login(parameters: parameters) {
      self.handleLoginSuccess()
    }
    let view = EnterPasswordView(purpose: purpose, isFlowPresented: .constant(false))
    
    navigateToIdentityVerificationCodeScreen(view: AnyView(view))
  }
  
  func handleIdentifyVerification(kind: IdentityVerificationCodeKind) {
    let viewModel = IdentityVerificationCodeViewModel(
      phoneNumber: phoneNumberWithRegionCode,
      otpCode: otpCode,
      kind: kind,
      handleOnboardingStep: self.handleOnboardingStep,
      forceLogout: self.forceLogout,
      setRouteToAccountLocked: self.setRouteToAccountLocked
    )
    let view = IdentityVerificationCodeView(viewModel: viewModel)
    
    navigateToIdentityVerificationCodeScreen(view: AnyView(view))
  }
  
  func navigateToIdentityVerificationCodeScreen(view: AnyView) {
    let delayTime = environmentService.networkEnvironment == .productionTest ? 0.5 : 0

    // Make sure we don't navigate immediately when the parent view has just appeared
    DispatchQueue.main.asyncAfter(deadline: .now() + delayTime) {
      self.onboardingDestinationObservable.verificationCodeDestinationView = .identityVerificationCode(view)
    }
  }
  
  func setupPortal(portalToken: String?) async {
    guard let portalToken else { return }
    
    do {
      try await registerPortalUseCase.execute(portalToken: portalToken)
    } catch {
      handlePortalError(error: error)
    }
  }
  
  func handlePortalError(error: Error) {
    guard let portalError = error as? LFPortalError else {
      toastMessage = error.userFriendlyMessage
      log.error(error.userFriendlyMessage)
      return
    }
    
    switch portalError {
    case .customError(let message):
      toastMessage = message
    default:
      toastMessage = portalError.localizedDescription
    }
    
    log.error(toastMessage ?? portalError.localizedDescription)
  }
}
