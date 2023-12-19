import Foundation
import LFUtilities
import OnboardingDomain
import Combine
import SwiftUI
import Factory
import NetspendSdk
import Services
import AccountData
import AccountDomain
import LFLocalizable
import BaseOnboarding
import EnvironmentService

@MainActor
final class VerificationCodeViewModel: VerificationCodeViewModelProtocol {
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
  
  unowned let coordinator: BaseOnboarding.BaseOnboardingDestinationObservable
  init(phoneNumber: String, requireAuth: [RequiredAuth], coordinator: BaseOnboarding.BaseOnboardingDestinationObservable) {
    self.requireAuth = requireAuth
    self.coordinator = coordinator
    formatPhoneNumber = Constants.Default.regionCode.rawValue + phoneNumber
    performAutoGetTwilioMessagesIfNeccessary()
  }
}

  // MARK: API
extension VerificationCodeViewModel {
  func handleAfterGetOTP(formatPhoneNumber: String, code: String) {
    guard !isShowLoading else { return }
    isShowLoading = true
    if requireAuth.count == 1 && requireAuth.contains(where: { $0 == .otp }) {
      analyticsService.track(event: AnalyticsEvent(name: .viewSignUpLogin))
      performVerifyOTPCode(formatPhoneNumber: formatPhoneNumber, code: code)
    } else {
      isShowLoading = false
      let isSSNCheck = requireAuth.contains(where: { $0 == .ssn })
      let isPassportCheck = requireAuth.contains(where: { $0 == .passport })
      let identityVerificationKind: IdentityVerificationCodeKind? = isSSNCheck
      ? .ssn
      : isPassportCheck ? .passport : nil
      if let kind = identityVerificationKind {
        let viewModel = IdentityVerificationCodeViewModel(phoneNumber: formatPhoneNumber, otpCode: code, kind: kind)
        let view = IdentityVerificationCodeView(viewModel: viewModel)
        coordinator
          .verificationDestinationView = .identityVerificationCode(AnyView(view))
      }
    }
  }
  
  func performVerifyOTPCode(formatPhoneNumber: String, code: String) {
    Task {
    #if DEBUG
      let start = CFAbsoluteTimeGetCurrent()
    #endif
      do {
        _ = try await loginUseCase.execute(phoneNumber: formatPhoneNumber, otpCode: code, lastID: .empty)
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
  
  func performGetOTP(formatPhoneNumber: String) {
    Task {
      defer { isShowLoading = false }
      isShowLoading = true
      do {
        _ = try await requestOtpUseCase.execute(phoneNumber: formatPhoneNumber)
        isShowLoading = false
      } catch {
        isShowLoading = false
        toastMessage = error.localizedDescription
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
        log.debug(code ?? "performGetTwilioMessagesIfNeccessary not found")
        guard let code = code else { return }
        self.handleAfterGetOTP(formatPhoneNumber: formatPhoneNumber, code: code)
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
      handleAfterGetOTP(formatPhoneNumber: formatPhoneNumber, code: otpCode)
    }
  }
  
  func resendOTP() {
    performGetOTP(formatPhoneNumber: formatPhoneNumber)
  }
  
  func handleError(error: Error) {
    isShowLoading = false
    guard let code = error.asErrorObject?.code else {
      toastMessage = error.localizedDescription
      return
    }
    switch code {
    case Constants.ErrorCode.userInactive.value:
      onboardingFlowCoordinator.set(route: .accountLocked)
    case Constants.ErrorCode.credentialsInvalid.value:
      toastMessage = LFLocalizable.VerificationCode.OtpInvalid.message
    default:
      toastMessage = error.localizedDescription
    }
  }
}

  // MARK: Private Functions
private extension VerificationCodeViewModel {
  
  @MainActor
  func checkOnboardingState() async {
    do {
      try await onboardingFlowCoordinator.apiFetchCurrentState()
    } catch {
      log.error(error.localizedDescription)
      onboardingFlowCoordinator.forcedLogout()
    }
  }
}
