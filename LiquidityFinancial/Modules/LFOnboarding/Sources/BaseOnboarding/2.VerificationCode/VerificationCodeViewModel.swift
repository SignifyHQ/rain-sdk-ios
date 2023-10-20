import LFUtilities
import Combine
import SwiftUI
import Factory
import LFServices
import LFLocalizable

public enum VerificationCodeNavigation {
  case identityVerificationCode(AnyView)
}

@MainActor
public protocol VerificationCodeViewModelProtocol: ObservableObject {
  var isNavigationToWelcome: Bool { get set }
  var isResendButonTimerOn: Bool { get set }
  var isShowText: Bool { get set }
  var isShowLoading: Bool { get set }
  var formatPhoneNumber: String { get set }
  var otpCode: String { get set }
  var timeString: String { get set }
  var toastMessage: String? { get set }
  var errorMessage: String? { get set }
  
  var requireAuth: [RequiredAuth] { get set }
  var cancellables: Set<AnyCancellable> { get set }
  
  var coordinator: BaseOnboardingDestinationView { get }
  init(phoneNumber: String, requireAuth: [RequiredAuth], coordinator: BaseOnboardingDestinationView)
  
  func handleAfterGetOTP(formatPhoneNumber: String, code: String)
  func performVerifyOTPCode(formatPhoneNumber: String, code: String)
  func performGetOTP(formatPhoneNumber: String)
  func performAutoGetTwilioMessagesIfNeccessary()
  func openSupportScreen()
  func onChangedOTPCode()
  func resendOTP()
  func handleError(error: Error)
}
