import Foundation
import LFUtilities
import OnboardingDomain

@MainActor
final class VerificationCodeViewModel: ObservableObject {
  @Published var isNavigationToWelcome: Bool = false
  @Published var isResendButonTimerOn = false
  @Published var isShowText: Bool = true
  @Published var isShowLoading: Bool = false
  @Published var formatPhoneNumber: String = ""
  @Published var otpCode: String = ""
  @Published var timeString: String = ""
  @Published var toastMessage: String?
  @Published var errorMessage: String?
  
  let requestOtpUserCase: RequestOTPUseCaseProtocol
  let loginUserCase: LoginUseCaseProtocol
  
  init(
    phoneNumber: String,
    requestOtpUserCase: RequestOTPUseCaseProtocol,
    loginUserCase: LoginUseCaseProtocol
  ) {
    formatPhoneNumber = Constants.Default.regionCode.rawValue + phoneNumber
    self.requestOtpUserCase = requestOtpUserCase
    self.loginUserCase = loginUserCase
  }
}

// MARK: API
extension VerificationCodeViewModel {
  func performVerifyOTPCode(formatPhoneNumber: String, code: String) {
    guard !isShowLoading else { return }
    isShowLoading = true
    Task {
      do {
        let _ = try await loginUserCase.execute(phoneNumber: formatPhoneNumber, code: code)
        isShowLoading = false
        isNavigationToWelcome = true
      } catch {
        isShowLoading = false
        toastMessage = error.localizedDescription
        log.error(error)
      }
    }
  }
  
  func performGetOTP(formatPhoneNumber: String) {
    Task {
      do {
        let _ = try await requestOtpUserCase.execute(phoneNumber: formatPhoneNumber)
        isShowLoading = false
      } catch {
        isShowLoading = false
        toastMessage = error.localizedDescription
      }
    }
  }
}
// MARK: View Helpers
extension VerificationCodeViewModel {
  func openIntercom() {
    // TODO: Will be implemented later
    // intercomService.openIntercom()
  }
  
  func onChangedOTPCode() {
    if otpCode.count == Constants.MaxCharacterLimit.verificationLimit.value {
      performVerifyOTPCode(formatPhoneNumber: formatPhoneNumber, code: otpCode)
    }
  }
  
  func resendOTP() {
    performGetOTP(formatPhoneNumber: formatPhoneNumber)
  }
}
