import Foundation
import Combine
import LFUtilities
import LFLocalizable
import SwiftUI
import OnboardingDomain
import OnboardingData
import Factory
import Services
import OnboardingComponents
import EnvironmentService

@MainActor
final class PhoneNumberViewModel: ObservableObject {

  enum OpenSafariType: String, Identifiable {
    var id: String {
      self.rawValue
    }
    
    case term
    case consent
    case privacy
  }
  
  enum Navigation {
    case verificationCode(AnyView)
  }
  
  var networkEnvironment: NetworkEnvironment {
    get {
      environmentService.networkEnvironment
    }
    set {
      environmentService.networkEnvironment = newValue
    }
  }
  
  @Published var isSecretMode: Bool = false
  @Published var isLoading: Bool = false
  @Published var isButtonDisabled: Bool = true
  @Published var navigation: Navigation?
  @Published var isShowConditions: Bool = false
  @Published var phoneNumber: String = ""
  @Published var toastMessage: String?
  
  @LazyInjected(\.environmentService) var environmentService
  @LazyInjected(\.onboardingRepository) var onboardingRepository
  @LazyInjected(\.customerSupportService) var customerSupportService
  @LazyInjected(\.noBankOnboardingFlowCoordinator) var onboardingFlowCoordinator
  
  let terms = L10N.Common.Term.Terms.attributeText
  let esignConsent = L10N.Common.Term.EsignConsent.attributeText
  let privacyPolicy = L10N.Common.Term.PrivacyPolicy.attributeText
  
  lazy var requestOtpUseCase: RequestOTPUseCaseProtocol = {
    RequestOTPUseCase(repository: onboardingRepository)
  }()
  lazy var loginUseCase: LoginUseCaseProtocol = {
    LoginUseCase(repository: onboardingRepository)
  }()
}

  // MARK: - API
extension PhoneNumberViewModel {
  func performGetOTP() {
    Task {
      defer { isLoading = false }
      isLoading = true
      do {
        let formatPhone = Constants.Default.regionCode.rawValue + phoneNumber
        
        /// Updates the network environment to the corresponding one if the given `number` is from a demo account.
        DemoAccountsHelper.shared.willSendOtp(for: formatPhone.reformatPhone)
        
        let parameters = OTPParameters(phoneNumber: formatPhone.reformatPhone)
        
        // All crypto apps are still using the old authentication flow. The new authentication flow will be applied later.
        let otpResponse = try await requestOtpUseCase.execute(isNewAuth: false, parameters: parameters)
        let requiredAuth = otpResponse.requiredAuth.map {
          RequiredAuth(rawValue: $0) ?? .unknow
        }
        let viewModel = VerificationCodeViewModel(
          phoneNumber: phoneNumber.reformatPhone,
          requireAuth: requiredAuth
        )
        let verificationCodeView = VerificationCodeView(
          viewModel: viewModel
        )
        navigation = .verificationCode(AnyView(verificationCodeView))

      } catch {
        handleError(error: error)
      }
    }
  }
}

  // MARK: - View Helpers
extension PhoneNumberViewModel {
  func getURL(tappedString: String) -> URL? {
    if tappedString == terms {
      return URL(string: LFUtilities.termsURL)
    }
    
    if tappedString == esignConsent {
      return URL(string: LFUtilities.consentURL)
    }
    
    if tappedString == privacyPolicy {
      return URL(string: LFUtilities.privacyURL)
    }
    
    return nil
  }
  
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }
  
  func onActiveSecretMode() {
    isSecretMode = true
  }
  
  func onChangedPhoneNumber(newValue: String) {
    let isPhoneNumber = newValue.trimWhitespacesAndNewlines().count == Constants.MaxCharacterLimit.phoneNumber.value
    let isAllowed = !newValue.trimWhitespacesAndNewlines().isEmpty && isPhoneNumber
    if isButtonDisabled == isAllowed {
      isButtonDisabled = !isAllowed
      withAnimation {
        self.isShowConditions = isAllowed
      }
    }
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
      onboardingFlowCoordinator.set(route: .accountLocked)
    default:
      toastMessage = error.userFriendlyMessage
    }
  }
}
