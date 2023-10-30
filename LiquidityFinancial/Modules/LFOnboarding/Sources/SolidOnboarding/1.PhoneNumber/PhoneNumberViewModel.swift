import Foundation
import Combine
import LFUtilities
import LFLocalizable
import SwiftUI
import OnboardingDomain
import Factory
import LFServices
import BaseOnboarding

@MainActor
final class PhoneNumberViewModel: ObservableObject, PhoneNumberViewModelProtocol {  
  unowned let destinationObservable: BaseOnboardingDestinationObservable
  init(coordinator: BaseOnboardingDestinationObservable) {
    self.destinationObservable = coordinator
  }
  
  @Published var isSecretMode: Bool = false
  @Published var isLoading: Bool = false
  @Published var isButtonDisabled: Bool = true
  @Published var navigation: PhoneNumberNavigation?
  @Published var isShowConditions: Bool = false
  @Published var phoneNumber: String = ""
  @Published var toastMessage: String?
  
  @LazyInjected(\.onboardingRepository) var onboardingRepository
  @LazyInjected(\.customerSupportService) var customerSupportService
  @LazyInjected(\.solidOnboardingFlowCoordinator) var solidOnboardingFlowCoordinator
  
  let terms = LFLocalizable.Term.Terms.attributeText
  let esignConsent = LFLocalizable.Term.EsignConsent.attributeText
  let privacyPolicy = LFLocalizable.Term.PrivacyPolicy.attributeText
  
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
        let otpResponse = try await requestOtpUseCase.execute(phoneNumber: formatPhone.reformatPhone)
        let requiredAuth = otpResponse.requiredAuth.map {
          RequiredAuth(rawValue: $0) ?? .unknow
        }
        let viewModel = VerificationCodeViewModel(
          phoneNumber: phoneNumber.reformatPhone,
          requireAuth: requiredAuth,
          coordinator: destinationObservable
        )
        let verificationCodeView = VerificationCodeView(
          viewModel: viewModel,
          coordinator: destinationObservable
        )
        destinationObservable
          .phoneNumberDestinationView = .verificationCode(AnyView(verificationCodeView))
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
  
  func environmentChange(environment: NetworkEnvironment) {
    self.customerSupportService.setUp(environment: environment)
  }
}

  // MARK: - Private Functions
private extension PhoneNumberViewModel {
  func handleError(error: Error) {
    guard let code = error.asErrorObject?.code else {
      toastMessage = error.localizedDescription
      return
    }
    switch code {
    case Constants.ErrorCode.userInactive.value:
      solidOnboardingFlowCoordinator.set(route: .accountLocked)
    default:
      toastMessage = error.localizedDescription
    }
  }
}
