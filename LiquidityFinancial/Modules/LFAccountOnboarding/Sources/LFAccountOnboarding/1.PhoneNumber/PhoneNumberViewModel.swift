import Combine
import LFUtilities
import LFLocalizable
import SwiftUI
import OnboardingDomain

@MainActor
public final class PhoneNumberViewModel: ObservableObject {
  @Published var isSecretMode: Bool = false
  @Published var isLoading: Bool = false
  @Published var isDisableButton: Bool = true
  @Published var isPushToVertificationView: Bool = false
  @Published var isShowConditions: Bool = false
  @Published var phoneNumber: String = ""
  @Published var toastMessage: String?
  
  let requestOtpUserCase: RequestOTPUseCaseProtocol
  let loginUseCase: LoginUseCaseProtocol
  let terms = LFLocalizable.Term.Terms.attributeText
  let esignConsent = LFLocalizable.Term.EsignConsent.attributeText
  let privacyPolicy = LFLocalizable.Term.PrivacyPolicy.attributeText
  
  public init(requestOtpUserCase: RequestOTPUseCaseProtocol, loginUseCase: LoginUseCaseProtocol) {
    self.requestOtpUserCase = requestOtpUserCase
    self.loginUseCase = loginUseCase
  }
}

// MARK: - API
extension PhoneNumberViewModel {
  func performGetOTP() {
    Task {
      do {
        let formatPhone = Constants.Default.regionCode.rawValue + phoneNumber
        let otpResponse = try await requestOtpUserCase.execute(phoneNumber: formatPhone)
        isLoading = false
        handleAfterGetOTP(isSuccess: otpResponse.success)
      } catch {
        isLoading = false
        toastMessage = error.localizedDescription
      }
    }
  }
}

// MARK: - API
private extension PhoneNumberViewModel {
  func handleAfterGetOTP(isSuccess: Bool) {
    if isSuccess {
      navigateToOTPVerification()
    }
  }
}

// MARK: - View Helpers
extension PhoneNumberViewModel {
  func getURL(tappedString: String) -> String {
    if tappedString == terms {
      return LFUtility.termsURL
    } else if tappedString == esignConsent {
      return LFUtility.consentURL
    } else {
      return LFUtility.privacyURL
    }
  }
  
  func onActiveSecretMode() {
    isSecretMode = true
  }
  
  func openIntercom() {
    // intercomService.openIntercom()
  }
  
  func onChangedPhoneNumber(newValue: String) {
    let isPhoneNumber = newValue.trimWhitespacesAndNewlines().count == Constants.MaxCharacterLimit.phoneNumber.value
    let isAllowed = !newValue.trimWhitespacesAndNewlines().isEmpty && isPhoneNumber
    if isDisableButton == isAllowed {
      isDisableButton = !isAllowed
      withAnimation {
        self.isShowConditions = isAllowed
      }
    }
  }
  
  func navigateToOTPVerification() {
    isPushToVertificationView = true
  }
}
