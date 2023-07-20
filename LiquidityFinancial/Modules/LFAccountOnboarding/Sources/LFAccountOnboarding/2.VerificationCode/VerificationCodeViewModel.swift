import Foundation
import LFUtilities
import OnboardingDomain
import Combine
import SwiftUI
import NetSpendData
import Factory
import NetspendSdk

@MainActor
final class VerificationCodeViewModel: ObservableObject {
  @Injected(\Container.userDataManager) var userDataManager
  @Published var isNavigationToWelcome: Bool = false
  @Published var isResendButonTimerOn = false
  @Published var isShowText: Bool = true
  @Published var isShowLoading: Bool = false
  @Published var formatPhoneNumber: String = ""
  @Published var otpCode: String = ""
  @Published var timeString: String = ""
  @Published var toastMessage: String?
  @Published var errorMessage: String?
  
  var cancellables: Set<AnyCancellable> = []
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
        _ = try await loginUserCase.execute(phoneNumber: formatPhoneNumber, code: code)
        let pnumber = formatPhoneNumber
          .replace(string: " ", replacement: "")
          .replace(string: "(", replacement: "")
          .replace(string: ")", replacement: "")
          .replace(string: "-", replacement: "")
          .trimWhitespacesAndNewlines()
        UserDefaults.phoneNumber = pnumber
        userDataManager.update(phone: pnumber)
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
        _ = try await requestOtpUserCase.execute(phoneNumber: formatPhoneNumber)
        isShowLoading = false
      } catch {
        isShowLoading = false
        toastMessage = error.localizedDescription
      }
    }
  }
  
  func performAutoGetTwilioMessagesIfNeccessary() {
      //guard DemoAccountsHelper.shared.shouldInterceptSms(number: formatPhoneNumber) else { return }
    DemoAccountsHelper.shared.getTwilioMessages(for: formatPhoneNumber)
      .sink { [weak self] code in
        guard let self else { return }
        log.debug(code ?? "performGetTwilioMessagesIfNeccessary not found")
        guard let code = code else { return }
        self.performVerifyOTPCode(formatPhoneNumber: formatPhoneNumber, code: code)
      }
      .store(in: &cancellables)
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
