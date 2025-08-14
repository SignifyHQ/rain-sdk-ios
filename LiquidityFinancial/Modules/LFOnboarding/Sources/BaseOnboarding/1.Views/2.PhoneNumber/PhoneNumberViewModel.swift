import AccountDomain
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
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.featureFlagManager) var featureFlagManager

  @LazyInjected(\.customerSupportService) var customerSupportService
  @LazyInjected(\.environmentService) var environmentService
  @LazyInjected(\.analyticsService) var analyticsService

  @Published var displayDropdown: Bool = false
  @Published var countryCodeList: [Country] = Country.allCases
  @Published var dropdownYPosition: CGFloat = 0
  
  @Published var isSecretMode: Bool = false
  @Published var isLoading: Bool = false
  @Published var isButtonEnabled: Bool = true
  
  @Published var isEsignAgreed: Bool = false
  @Published var areTermsAgreed: Bool = false
  @Published var isPrivacyAgreed: Bool = false
  
  @Published var shouldAgreeToTerms: Bool?
  @Published var didAgreeToAllTerms: Bool = false
  
  @Published var selectedCountry: Country = .US
  @Published var phoneNumber: String = ""
  @Published var promocode: String = "" {
    didSet {
      inlineError = nil
    }
  }
  
  @Published var toastMessage: String?
  @Published var inlineError: String?
  
  var networkEnvironment: NetworkEnvironment {
    get {
      environmentService.networkEnvironment
    }
    set {
      environmentService.networkEnvironment = newValue
    }
  }
  
  let terms = L10N.Common.Term.Terms.attributeText
  let esignConsent = L10N.Common.Term.EsignConsent.attributeText
  let privacyPolicy = L10N.Common.Term.PrivacyPolicy.attributeText
  
  lazy var checkAccountExistingUseCase: CheckAccountExistingUseCaseProtocol = {
    CheckAccountExistingUseCase(repository: onboardingRepository)
  }()
  
  lazy var requestOtpUseCase: RequestOTPUseCaseProtocol = {
    RequestOTPUseCase(repository: onboardingRepository)
  }()
  
  lazy var loginUseCase: LoginUseCaseProtocol = {
    LoginUseCase(repository: onboardingRepository)
  }()
  
  lazy var applyPromocodeUseCase: ApplyPromoCodeUseCaseProtocol = {
    ApplyPromoCodeUseCase(repository: accountRepository)
  }()
  
  private let handleOnboardingStep: (() async throws -> Void)?
  private let forceLogout: (() -> Void)?
  private let setRouteToAccountLocked: (() -> Void)?
  
  public init(
    handleOnboardingStep: (() async throws -> Void)?,
    forceLogout: (() -> Void)?,
    setRouteToAccountLocked: (() -> Void)?
  ) {
    self.handleOnboardingStep = handleOnboardingStep
    self.forceLogout = forceLogout
    self.setRouteToAccountLocked = setRouteToAccountLocked
    
    UserDefaults.isStartedWithLoginFlow = true
    observeInput()
  }
}

// MARK: - APIs Handler
extension PhoneNumberViewModel {
  func performGetOTP() {
    Task {
      defer {
        isLoading = false
      }
      
      inlineError = nil
      isLoading = true
      
      let phoneNumberWithRegionCode = selectedCountry.phoneCode + phoneNumber
      let formattedPhoneNumber = phoneNumberWithRegionCode.reformatPhone
      let promocodeTrimmed = promocode.trimWhitespacesAndNewlines()
      
      do {
        if shouldAgreeToTerms == nil {
          
          // Check if the user is new or existing
          let parameters = CheckAccountExistingParameters(phoneNumber: formattedPhoneNumber)
          let checkResponse = try await checkAccountExistingUseCase.execute(parameters: parameters)
          let doesAccountExist = checkResponse.exists
          
          // Proceed with login for existing user
          if doesAccountExist {
            try await requestOTPAndProceed(with: formattedPhoneNumber)
            
            // Show the promocode field and terms to new users
          } else {
            shouldAgreeToTerms = true
          }
          
          // Proceed to login for new users after they agree to terms
        } else {
          
          // Apply promocode first if it is entered
          if !promocodeTrimmed.isEmpty {
            try await applyPromocodeUseCase.execute(phoneNumber: formattedPhoneNumber, promocode: promocodeTrimmed)
          }
          
          // Request OTP if promocode was applied successfully or not used
          try await requestOTPAndProceed(with: formattedPhoneNumber)
        }
      } catch {
        handleError(error: error)
      }
    }
  }
  
  private func requestOTPAndProceed(with formattedPhoneNumber: String) async throws {
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
    guard let code = error.asErrorObject?.code
    else {
      toastMessage = error.userFriendlyMessage
      
      return
    }
    
    switch code {
    case Constants.ErrorCode.userInactive.value:
      setRouteToAccountLocked?()
    case Constants.ErrorCode.invalidPromoCode.value:
      inlineError = error.userFriendlyMessage
    default:
      toastMessage = error.userFriendlyMessage
    }
  }
  
  private func observeInput() {
    Publishers.CombineLatest3($isEsignAgreed, $areTermsAgreed, $isPrivacyAgreed)
      .receive(on: DispatchQueue.main)
      .map { isEsignAgreed, areTermsAgreed, isPrivacyAgreed in
        isEsignAgreed && areTermsAgreed && isPrivacyAgreed
      }
      .assign(to: &$didAgreeToAllTerms)
    
    Publishers.CombineLatest3($phoneNumber, $shouldAgreeToTerms, $didAgreeToAllTerms)
      .receive(on: DispatchQueue.main)
      .map { [weak self] phoneNumber, shouldAgreeToTerms, didAgreeToAllTerms in
        guard let self else { return false }
        
        let phoneNumberMinLength = Constants.MinCharacterLimit.phoneNumber.value
        let isPhoneNumberFormatted = phoneNumber.reformatPhone.count >= phoneNumberMinLength
        
        let shouldActivateForPhoneNumberChekck = isPhoneNumberFormatted && (shouldAgreeToTerms == nil)
        let shouldActivateForOtp = ((shouldAgreeToTerms == true) && isEsignAgreed && areTermsAgreed && isPrivacyAgreed)
        
        return shouldActivateForPhoneNumberChekck || shouldActivateForOtp
      }
      .assign(to: &$isButtonEnabled)
    
    $phoneNumber
      .receive(on: DispatchQueue.main)
      .map { [weak self] _ in
        self?.isEsignAgreed = false
        self?.areTermsAgreed = false
        self?.isPrivacyAgreed = false
        
        return nil
      }
      .assign(to: &$shouldAgreeToTerms)
  }
  
  func navigateToVerificationCodeScreen(requiredAuthentication: [String]) {
    let requiredAuth = requiredAuthentication.map {
      RequiredAuth(rawValue: $0) ?? .unknow
    }
    
    let viewModel = VerificationCodeViewModel(
      phoneCountryCode: selectedCountry.phoneCode,
      phoneNumber: phoneNumber.reformatPhone,
      requireAuth: requiredAuth,
      handleOnboardingStep: self.handleOnboardingStep,
      forceLogout: self.forceLogout,
      setRouteToAccountLocked: self.setRouteToAccountLocked
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
