import BaseOnboarding
import Combine
import Factory
import Foundation
import LFLocalizable
import LFStyleGuide
import LFUtilities
import OnboardingData
import OnboardingDomain
import PortalDomain
import Services

@MainActor
public final class PhoneEmailAuthViewModel: ObservableObject {
  @LazyInjected(\.analyticsService) var analyticsService
  @LazyInjected(\.environmentService) var environmentService
  @LazyInjected(\.customerSupportService) var customerSupportService
  
  @LazyInjected(\.onboardingCoordinator) var onboardingCoordinator
  
  @LazyInjected(\.accountDataManager) var accountDataManager
  
  @LazyInjected(\.onboardingRepository) var onboardingRepository
  @LazyInjected(\.portalRepository) var portalRepository
  
  @Published var authType: AuthType
  @Published var currentStep: AuthStep = .input
  
  @Published var navigation: OnboardingNavigation?
  
  @Published var isShowingPhoneCodeCountrySelection: Bool = false
  
  @Published var countryList: [Country] = Country.allCases
  @Published var selectedCountry: Country = .US
  @Published var selectedCountryDisplayValue: String = .empty
  @Published var countrySearchQuery: String = .empty
  
  @Published var phoneNumber: String = .empty
  @Published var emailAddress: String = .empty
  @Published var loginErrorMessage: String? = nil
  
  @Published var otp: String = .empty
  @Published var otpErrorMessage: String? = nil
  
  @Published var isTimerActive: Bool = false
  @Published var remainingTime: Int = 30
  @Published var showResendButton: Bool = false
  
  @Published var shouldDisplayTerms: Bool?
  
  @Published var isEsignAgreed: Bool = false
  @Published var areTermsAgreed: Bool = false
  @Published var isPrivacyAgreed: Bool = false
  
  private var timerSubscription: AnyCancellable?
  
  @Published var isLoading: Bool = false
  @Published var currentToast: ToastData? = nil
  
  // Use case for checking if the user is registered with the given phone number
  lazy var checkIfAccountExistsUseCase: CheckAccountExistingUseCaseProtocol = {
    CheckAccountExistingUseCase(repository: onboardingRepository)
  }()
  // Use case for requesting an OTP to the given phone number
  lazy var requestOtpUseCase: RequestOTPUseCaseProtocol = {
    RequestOTPUseCase(repository: onboardingRepository)
  }()
  // Use case for confirming the OTP and performing the login
  lazy var loginUseCase: LoginUseCaseProtocol = {
    LoginUseCase(repository: onboardingRepository)
  }()
  // Use case for initializing Portal client with the access token after login
  lazy var initializePortalUseCase: RegisterPortalUseCaseProtocol = {
    RegisterPortalUseCase(repository: portalRepository)
  }()
  
  var isContinueButtonEnabled: Bool {
    if currentStep == .input {
      // Check if the email/phone inputs are valid values
      let isEmailValid = authType.authMethod == .email && emailAddress.isValidEmail()
      let isPhoneNumberValid = authType.authMethod == .phone && (phoneNumber.reformatPhone.count >= Constants.MinCharacterLimit.phoneNumber.value)
      let isInputValid = isEmailValid || isPhoneNumberValid
      // Check if the terms are accepted (if needed)
      let areCheckboxesValid = !shouldDisplayTerms.falseIfNil || (isEsignAgreed && areTermsAgreed && isPrivacyAgreed)
      
      // Final decision = valid input + valid terms state
      return isInputValid && areCheckboxesValid
    }
    
    if currentStep == .verification {
      return otp.count == 6
    }
    
    return false
  }
  
  let terms = L10N.Common.Term.Terms.attributeText
  let esignConsent = L10N.Common.Term.EsignConsent.attributeText
  let privacyPolicy = L10N.Common.Term.PrivacyPolicy.attributeText
  
  init(
    authType: AuthType
  ) {
    self.authType = authType
    
    bindCountrySelection()
    bindSearchQueries()
    
    // Check if the country was chosen in the onboarding and pre-select the country phone code
    if let countryCode = accountDataManager.userInfomationData.countryCode,
       let country = Country(rawValue: countryCode) {
      selectedCountry = country
    }
  }
  
  deinit {
    timerSubscription?.cancel()
  }
}

// MARK: - Binding Observables
extension PhoneEmailAuthViewModel {
  private func bindCountrySelection() {
    $selectedCountry
      .map { country in
        country.flagEmoji() + country.phoneCode
      }
      .assign(
        to: &$selectedCountryDisplayValue
      )
  }
  
  private func bindSearchQueries() {
    $countrySearchQuery
      .map { searchQuery in
        let trimmedQuery = searchQuery.trimWhitespacesAndNewlines().lowercased()
        
        guard !trimmedQuery.isEmpty
        else {
          return Country.allCases
        }
        
        return Country.allCases.filter { country in
          country.title.lowercased().contains(trimmedQuery) || country.rawValue.lowercased().contains(trimmedQuery)
        }
      }
      .assign(
        to: &$countryList
      )
  }
}

// MARK: - Handling UI/UX Logic
extension PhoneEmailAuthViewModel {
  private func startCountdown() {
    remainingTime = 30
    isTimerActive = true
    showResendButton = false
    
    timerSubscription = Timer.publish(
      every: 1,
      on: .main,
      in: .common
    )
    .autoconnect()
    .sink { [weak self] _ in
      guard let self = self
      else {
        return
      }
      
      if self.remainingTime > 0 {
        self.remainingTime -= 1
      } else {
        self.stopTimer()
        // Only show resend button if the user is on the verification step
        self.showResendButton = (currentStep == .verification)
      }
    }
  }
  
  func stopTimer() {
    timerSubscription?.cancel()
    isTimerActive = false
  }
}

// MARK: - Handling Interations
extension PhoneEmailAuthViewModel {
  func onSupportButtonTap() {
    hideSelections()
    customerSupportService.openSupportScreen()
  }
  
  func onContinueButtonTap() {
    Task {
      defer {
        isLoading = false
      }
      
      isLoading = true
      loginErrorMessage = nil
      otpErrorMessage = nil
      
      hideSelections()
      
      do {
        // On the input step, check if account exists for
        // given phone number/email and proceed accordingly
        if currentStep == .input {
          var isExistingUser = false
          // Only check if the account exists when it's not determinted yet
          if !shouldDisplayTerms.falseIfNil {
            isExistingUser = try await checkIfAccountExists()
          }
          
          switch authType {
          case .login:
            try await handleLogin(isExistingUser: isExistingUser)
          case .signup:
            if isExistingUser {
              try await handleLogin(isExistingUser: isExistingUser)
            } else {
              try await handleSignup()
            }
          }
          
          return
        }
        
        if currentStep == .verification {
          try await handleOtpVerification()
          
          return
        }
      } catch {
        currentToast = ToastData(
          type: .error,
          body: error.userFriendlyMessage
        )
      }
    }
  }
  
  func onResendCodeButtonTap(
  ) {
    Task {
      defer {
        isLoading = false
      }
      
      isLoading = true
      
      do {
        try await requestOtp()
        
        startCountdown()
        currentToast = ToastData(
          type: .success,
          title: nil,
          body: "Your OTP code has been resent. Please check your \(authType.authMethod == .email ? "email" : "SMS")."
        )
      } catch {
        currentToast = ToastData(
          type: .error,
          body: error.userFriendlyMessage
        )
      }
    }
  }
  
  func onSwitchAuthMethodButtonTap() {
    authType = authType.toggleMethod()
    resetInputs()
  }
  
  func onSwitchToSignupButtonTap() {
    authType = .signup(authType.authMethod)
    resetInputs()
  }
  
  func hideSelections() {
    isShowingPhoneCodeCountrySelection = false
  }
  
  func resetInputs() {
    currentStep = .input
    
    loginErrorMessage = nil
    
    otp = .empty
    otpErrorMessage = nil
  }
}

// MARK: - API Calls
extension PhoneEmailAuthViewModel {
  private func checkIfAccountExists(
  ) async throws -> Bool  {
    let parameters = CheckAccountExistingParameters(
      phoneNumber: apiRequestFormattedPhoneNumber,
      email: apiRequestFormattedEmailAddress
    )
    
    let response = try await checkIfAccountExistsUseCase.execute(parameters: parameters)
    return response.exists
  }
  
  private func handleLogin(
    isExistingUser: Bool
  ) async throws {
    guard isExistingUser
    else {
      loginErrorMessage = authType.authMethod == .phone ? "Sorry, we can’t find an account with this phone number" : "Sorry, we can’t find an account with this email address"
      
      return
    }
    
    // Hide the onboarding steps for existing user who entered the flow from signup button
    if case .signup = authType {
      authType = .login(authType.authMethod)
    }
    
    // Handle the existing user flow -> request OTP and take to OTP input
    try await requestOtp()
    
    currentStep = .verification
    startCountdown()
  }
  
  private func handleSignup(
  ) async throws {
    if shouldDisplayTerms == true {
      shouldDisplayTerms = false
      
      try await requestOtp()
      
      currentStep = .verification
      startCountdown()
      
      return
    }
    
    if currentStep == .input {
      shouldDisplayTerms = true
      
      return
    }
  }
  
  private func requestOtp(
  ) async throws {
    let parameters = OTPParameters(
      phoneNumber: apiRequestFormattedPhoneNumber,
      email: apiRequestFormattedEmailAddress
    )
    
    let _ = try await requestOtpUseCase.execute(isNewAuth: false, parameters: parameters)
    performAutoOtpFetchIfNeeded()
  }
  
  private func handleOtpVerification(
  ) async throws {
    do {
      let loginRequestParameters = LoginParameters(
        phoneNumber: apiRequestFormattedPhoneNumber,
        email: apiRequestFormattedEmailAddress,
        otpCode: otp
      )
      
      let loginResponse = try await loginUseCase.execute(isNewAuth: false, parameters: loginRequestParameters)
      // Initialize Portal client after successful login
      try await initializePortalClient(with: loginResponse.portalSessionToken)
      // Handle the next steps
      try await handleLoginSuccess()
      // Stor successful login analytics event
      analyticsLoginEvent(isSuccess: true, eventName: .loggedIn)
    } catch {
      analyticsLoginEvent(isSuccess: false, eventName: .otpVerificationError)
      
      if error.asErrorObject?.inlineError == .otpIncorrect {
        otpErrorMessage = "Incorrect code"
        
        return
      }
      
      throw error
    }
  }
  
  private func initializePortalClient(
    with apiKey: String?
  ) async throws {
    guard let apiKey
    else {
      throw LFPortalError.sessionTokenUnavailable
    }
    
    try await initializePortalUseCase.execute(portalToken: apiKey)
  }
  
  // Automatically get the OTP in DEV enviroment to simplify testing
  // TODO(Volo): Old code below, will need to revisit later
  private func performAutoOtpFetchIfNeeded(
  ) {
    guard environmentService.networkEnvironment == .productionTest,
          let formattedPhoneNumber = apiRequestFormattedPhoneNumber
    else {
      return
    }
    
    DemoAccountsHelper
      .shared
      .getOTPInternal(
        for: formattedPhoneNumber
      )
      .removeDuplicates()
      .receive(
        on: DispatchQueue.main
      )
      .map { otp in
        log.debug(otp ?? "Could not retrieve OTP from Twilio in DEV environment")
        
        return otp
      }
      .compactMap { otp in
        otp
      }
      .assign(
        to: &$otp
      )
  }
  
  private func handleLoginSuccess(
  ) async throws {
    // Update user object with the phone number or email from input (not persistent)
    accountDataManager.update(phone: apiRequestFormattedPhoneNumber)
    accountDataManager.update(email: apiRequestFormattedEmailAddress)
    // Update user defaults with the phone number or email from input (persistent)
    accountDataManager.phoneCode = authType.authMethod == .phone ? selectedCountry.phoneCode : .empty
    accountDataManager.phoneNumber = authType.authMethod == .phone ? phoneNumber.trimmedPhoneNumberOrSsn : .empty
    accountDataManager.userEmail = apiRequestFormattedEmailAddress ?? .empty
    // Navigate to next step
    navigation = try await onboardingCoordinator.getOnboardingNavigation()
  }
  
  private func analyticsLoginEvent(
    isSuccess: Bool,
    eventName: AnalyticsEventName
  ) {
    if authType.authMethod == .phone {
      analyticsService.set(params: ["phoneVerified": true])
    } else {
      analyticsService.set(params: ["emailVerified": true])
    }
    
    analyticsService.track(event: AnalyticsEvent(name: eventName))
  }
}

// MARK: - Helper Functions
extension PhoneEmailAuthViewModel {
  func getURL(
    tappedString: String
  ) -> URL? {
    let urlMapping: [String: String] = [
      terms: LFUtilities.termsURL,
      esignConsent: LFUtilities.consentURL,
      privacyPolicy: LFUtilities.privacyURL
    ]
    
    return urlMapping[tappedString].flatMap { URL(string: $0) }
  }
  
  private var apiRequestFormattedPhoneNumber: String? {
    let fullPhoneNumber = selectedCountry.phoneCode + phoneNumber
    let phoneNumberTrimmed = fullPhoneNumber.trimmedPhoneNumberOrSsn
    
    return authType.authMethod == .phone ? phoneNumberTrimmed : nil
  }
  
  private var apiRequestFormattedEmailAddress: String? {
    authType.authMethod == .email ? emailAddress.trimWhitespacesAndNewlines() : nil
  }
}

// MARK: - Private Enums
extension PhoneEmailAuthViewModel {
  enum AuthType {
    case login(AuthMethod)
    case signup(AuthMethod)
    
    func toggleMethod() -> AuthType {
      switch self {
      case .login(let authMethod):
        return .login(authMethod == .email ? .phone : .email)
      case .signup(let authMethod):
        return .signup(authMethod == .email ? .phone : .email)
      }
    }
    
    var authMethod: AuthMethod {
      switch self {
      case .login(let authMethod):
        return authMethod
      case .signup(let authMethod):
        return authMethod
      }
    }
  }
  
  enum AuthMethod {
    case phone
    case email
  }
  
  enum AuthStep {
    case input
    case verification
  }
  
  enum SafariNavigation: String, Identifiable {
    var id: String {
      self.rawValue
    }
    
    case term
    case consent
    case privacy
  }
}
