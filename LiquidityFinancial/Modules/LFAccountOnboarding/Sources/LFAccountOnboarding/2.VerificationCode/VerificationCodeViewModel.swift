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
  @Injected(\.onboardingRepository) var onboardingRepository
  @LazyInjected(\.onboardingFlowCoordinator) var onboardingFlowCoordinator
  
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
  lazy var requestOtpUseCase: RequestOTPUseCaseProtocol = {
    RequestOTPUseCase(repository: onboardingRepository)
  }()
  lazy var loginUseCase: LoginUseCaseProtocol = {
    LoginUseCase(repository: onboardingRepository)
  }()
  
  init(phoneNumber: String) {
    formatPhoneNumber = Constants.Default.regionCode.rawValue + phoneNumber
  }
}

// MARK: API
extension VerificationCodeViewModel {
  func performVerifyOTPCode(formatPhoneNumber: String, code: String) {
    guard !isShowLoading else { return }
    isShowLoading = true
    Task {
      do {
        _ = try await loginUseCase.execute(phoneNumber: formatPhoneNumber, code: code)
        let pnumber = formatPhoneNumber
          .replace(string: " ", replacement: "")
          .replace(string: "(", replacement: "")
          .replace(string: ")", replacement: "")
          .replace(string: "-", replacement: "")
          .trimWhitespacesAndNewlines()
        userDataManager.update(phone: pnumber)
        userDataManager.stored(phone: pnumber)
        checkOnboardingState {
          self.isShowLoading = false
        }
      } catch {
        self.isShowLoading = false
        toastMessage = error.localizedDescription
        log.error(error)
      }
    }
  }
  
  func performGetOTP(formatPhoneNumber: String) {
    Task {
      do {
        _ = try await requestOtpUseCase.execute(phoneNumber: formatPhoneNumber)
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
  
  func checkOnboardingState(onCompletion: @escaping () -> Void) {
    Task { @MainActor in
      defer { onCompletion() }
      do {
        let onboardingState = try await onboardingRepository.getOnboardingState(sessionId: userDataManager.sessionID)
        if onboardingState.missingSteps.isEmpty {
          onboardingFlowCoordinator.set(route: .dashboard)
        } else {
          let states = onboardingState.mapToEnum()
          if states.isEmpty {
            let workflowsMissingStep = WorkflowsMissingStep.allCases.map { $0.rawValue }
            if (onboardingState.missingSteps.first(where: { workflowsMissingStep.contains($0) }) != nil) {
              onboardingFlowCoordinator.set(route: .kycReview)
            } else {
              //TODO: Tony need review
              onboardingFlowCoordinator.set(route: .dashboard)
            }
          } else {
            if states.contains(OnboardingMissingStep.netSpendCreateAccount) {
              isNavigationToWelcome = true
            } else if states.contains(OnboardingMissingStep.dashboardReview) {
              onboardingFlowCoordinator.set(route: .kycReview)
            } else if states.contains(OnboardingMissingStep.zeroHashAccount) {
                //TODO: Tony review it
            } else if states.contains(OnboardingMissingStep.cardProvision) {
                //TODO: Tony review it
            }
          }
        }
      } catch {
        isNavigationToWelcome = true
        log.error(error.localizedDescription)
      }
    }
  }
}
// MARK: View Helpers
extension VerificationCodeViewModel {  
  func onChangedOTPCode() {
    if otpCode.count == Constants.MaxCharacterLimit.verificationLimit.value {
      performVerifyOTPCode(formatPhoneNumber: formatPhoneNumber, code: otpCode)
    }
  }
  
  func resendOTP() {
    performGetOTP(formatPhoneNumber: formatPhoneNumber)
  }
}
