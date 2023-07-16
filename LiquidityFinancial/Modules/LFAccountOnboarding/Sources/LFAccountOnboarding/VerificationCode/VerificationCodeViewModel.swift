import Foundation
import LFUtilities
import OnboardingDomain

@MainActor
final class VerificationCodeViewModel: ObservableObject {
  @Published var isPushToSSNView: Bool = false
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
  func performVerifyOTPCode() {
    guard !isShowLoading else { return }
    isShowLoading = true
    Task {
      do {
        let accessTokens = try await loginUserCase.execute(phoneNumber: formatPhoneNumber, code: otpCode)
        isShowLoading = false
        print("Debug - \(accessTokens)")
      } catch {
        isShowLoading = false
        print("Debug - \(error)")
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
      performVerifyOTPCode()
    }
  }
}
