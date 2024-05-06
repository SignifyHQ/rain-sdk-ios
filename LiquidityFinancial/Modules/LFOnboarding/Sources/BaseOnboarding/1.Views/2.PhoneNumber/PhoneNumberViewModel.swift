import Foundation
import Combine
import LFUtilities
import LFLocalizable
import SwiftUI
import OnboardingDomain
import OnboardingData
import Factory
import Services
import EnvironmentService

// MARK: - PhoneNumberNavigation
public enum PhoneNumberNavigation {
  case verificationCode(AnyView)
}

// MARK: - PhoneNumberViewModel
@MainActor
public final class PhoneNumberViewModel: ObservableObject {
  @InjectedObject(\.onboardingDestinationObservable) var onboardingDestinationObservable
  
  @LazyInjected(\.onboardingRepository) var onboardingRepository
  @LazyInjected(\.featureFlagManager) var featureFlagManager

  @LazyInjected(\.customerSupportService) var customerSupportService
  @LazyInjected(\.environmentService) var environmentService
  @LazyInjected(\.analyticsService) var analyticsService

  @Published var isSecretMode: Bool = false
  @Published var isLoading: Bool = false
  @Published var isButtonDisabled: Bool = true
  @Published var isShowConditions: Bool = false
  @Published var phoneNumber: String = ""
  @Published var toastMessage: String?
  
  let terms = L10N.Common.Term.Terms.attributeText
  let esignConsent = L10N.Common.Term.EsignConsent.attributeText
  let privacyPolicy = L10N.Common.Term.PrivacyPolicy.attributeText
  
  lazy var requestOtpUseCase: RequestOTPUseCaseProtocol = {
    RequestOTPUseCase(repository: onboardingRepository)
  }()
  
  lazy var loginUseCase: LoginUseCaseProtocol = {
    LoginUseCase(repository: onboardingRepository)
  }()
  
  var networkEnvironment: NetworkEnvironment {
    get {
      environmentService.networkEnvironment
    }
    set {
      environmentService.networkEnvironment = newValue
    }
  }
  
  private let handleOnboardingStep: (() async throws -> Void)?
  private let forceLogout: (() -> Void)?
  private let setRouteToAccountLocked: (() -> Void)?
  private let recoverWalletView: AnyView?
  
  private var cancellables: Set<AnyCancellable> = []
  
  public init(
    handleOnboardingStep: (() async throws -> Void)?,
    forceLogout: (() -> Void)?,
    setRouteToAccountLocked: (() -> Void)?,
    recoverWalletView: AnyView? = nil
  ) {
    self.handleOnboardingStep = handleOnboardingStep
    self.forceLogout = forceLogout
    self.setRouteToAccountLocked = setRouteToAccountLocked
    self.recoverWalletView = recoverWalletView
    
    UserDefaults.isStartedWithLoginFlow = true
    observePasswordInput()
  }
}

// MARK: - APIs Handler
extension PhoneNumberViewModel {
  func performGetOTP() {
    Task {
      defer { isLoading = false }
      isLoading = true
      
      do {
        let phoneNumberWithRegionCode = Constants.Default.regionCode.rawValue + phoneNumber
        let formattedPhoneNumber = phoneNumberWithRegionCode.reformatPhone
        
        // Adjusts the network environment based on the provided number if it belongs to a demo account."
        DemoAccountsHelper.shared.willSendOtp(for: formattedPhoneNumber)
        
        /*
         All cryptocurrency applications are currently utilizing the old authentication flow.
         The implementation of the new authentication flow will be postponed until a later time.
         */
        let parameters = OTPParameters(phoneNumber: formattedPhoneNumber)
        let isNewAuth = LFUtilities.cryptoEnabled ? false : featureFlagManager.isFeatureFlagEnabled(.mfa)
        let otpResponse = try await requestOtpUseCase.execute(
          isNewAuth: isNewAuth,
          parameters: parameters
        )
        
        navigateToVerificationCodeScreen(requiredAuthentication: otpResponse.requiredAuth)
      } catch {
        handleError(error: error)
      }
    }
  }
}

// MARK: - View Handler
extension PhoneNumberViewModel {
  func onAppear() {
    analyticsService.track(event: AnalyticsEvent(name: .phoneVerified))
  }
  
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }
  
  func onActiveSecretMode() {
    isSecretMode = true
  }
  
  func getURL(tappedString: String) -> URL? {
    let urlMapping: [String: String] = [
      terms: LFUtilities.termsURL,
      esignConsent: LFUtilities.consentURL,
      privacyPolicy: LFUtilities.privacyURL
    ]
    
    return urlMapping[tappedString].flatMap { URL(string: $0) }
  }
}

// MARK: - Private Functions
private extension PhoneNumberViewModel {
  func handleError(error: Error) {
    guard let code = error.asErrorObject?.code else {
      toastMessage = error.userFriendlyMessage
      return
    }
    switch code {
    case Constants.ErrorCode.userInactive.value:
      setRouteToAccountLocked?()
    default:
      toastMessage = error.userFriendlyMessage
    }
  }
  
  func observePasswordInput() {
    $phoneNumber
      .receive(on: DispatchQueue.main)
      .sink { [weak self] phoneNumber in
        guard let self else { return }
        let phoneNumberMaxLength = Constants.MaxCharacterLimit.phoneNumber.value
        let isPhoneNumberFormatted = phoneNumber.trimWhitespacesAndNewlines().count == phoneNumberMaxLength
        
        self.isButtonDisabled = !isPhoneNumberFormatted
        withAnimation {
          self.isShowConditions = isPhoneNumberFormatted
        }
      }
      .store(in: &cancellables)
  }
  
  func navigateToVerificationCodeScreen(requiredAuthentication: [String]) {
    let requiredAuth = requiredAuthentication.map {
      RequiredAuth(rawValue: $0) ?? .unknow
    }
    let viewModel = VerificationCodeViewModel(
      phoneNumber: phoneNumber.reformatPhone,
      requireAuth: requiredAuth,
      handleOnboardingStep: self.handleOnboardingStep,
      forceLogout: self.forceLogout,
      setRouteToAccountLocked: self.setRouteToAccountLocked,
      recoverWalletView: self.recoverWalletView
    )
    let verificationCodeView = AnyView(VerificationCodeView(viewModel: viewModel))
    
    onboardingDestinationObservable.phoneNumberDestinationView = .verificationCode(
      verificationCodeView
    )
  }
}

// MARK: - Types
extension PhoneNumberViewModel {
  enum OpenSafariType: String, Identifiable {
    var id: String {
      self.rawValue
    }
    
    case term
    case consent
    case privacy
  }
}
