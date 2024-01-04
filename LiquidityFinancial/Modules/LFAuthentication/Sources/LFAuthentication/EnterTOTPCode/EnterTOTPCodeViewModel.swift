import AccountData
import AccountDomain
import OnboardingDomain
import OnboardingData
import Combine
import Foundation
import Factory
import LFStyleGuide
import LFUtilities
import LFLocalizable
import LFFeatureFlags

@MainActor
final class EnterTOTPCodeViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.onboardingRepository) var onboardingRepository
  @LazyInjected(\.customerSupportService) var customerSupportService

  @Published var isTOTPCodeEntered: Bool = false
  @Published var isVerifying: Bool = false
  @Published var totpCode: String = .empty
  @Published var toastMessage: String?
  @Published var errorMessage: String?
  @Published var navigation: Navigation?
  @Published var popup: Popup?
  
  let totpCodeLength = Constants.MaxCharacterLimit.mfaCode.value
  
  let purpose: EnterTOTPCodePurpose
  private var cancellable: Set<AnyCancellable> = []

  lazy var disableMFAUseCase: DisableMFAUseCaseProtocol = {
    DisableMFAUseCase(repository: accountRepository)
  }()
  
  lazy var loginUseCase: LoginUseCaseProtocol = {
    LoginUseCase(repository: onboardingRepository)
  }()
  
  private var subscribers: Set<AnyCancellable> = []

  init(purpose: EnterTOTPCodePurpose) {
    self.purpose = purpose
    observeTOTPInput()
  }
}

// MARK: - APIs
extension EnterTOTPCodeViewModel {
  private func disableMFAAuthentication() {
    Task {
      defer { isVerifying = false }
      isVerifying = true
      
      do {
        let response = try await disableMFAUseCase.execute(code: totpCode)
        if response.success {
          popup = .mfaTurnedOff
          accountDataManager.update(mfaEnabled: false)
        }
      } catch {
        handleError(error: error)
      }
    }
  }
  
  private func loginWithTOTPCode(parameters: LoginParameters, completion: @escaping (() -> Void)) {
    Task {
      isVerifying = true

      NotificationCenter.default
        .publisher(for: .didLoginComplete)
        .sink { [weak self] _ in
          guard let self else {
            return
          }
          self.isVerifying = false
        }
        .store(in: &subscribers)
      
      do {
        let parameters = LoginParameters(
          phoneNumber: parameters.phoneNumber,
          otpCode: parameters.code,
          verification: Verification(type: parameters.verification?.type ?? .empty, secret: totpCode)
        )
        _ = try await loginUseCase.execute(
          isNewAuth: LFFeatureFlagContainer.isMultiFactorAuthFeatureFlagEnabled,
          parameters: parameters
        )
        completion()
      } catch {
        isVerifying = false
        handleError(error: error)
      }
    }
  }
}

// MARK: - View Helpers
extension EnterTOTPCodeViewModel {
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }
  
  func didUseRecoveryCodeLinkTap(popToPreviousView: @escaping (() -> Void)) {
    var recoveryCodePurpose: RecoveryCodePurpose
    
    switch purpose {
    case .disableMFA:
      recoveryCodePurpose = .disableMFA(completion: popToPreviousView)
    case let .login(parameters, fallbackType, completion):
      let parameters = LoginParameters(
        phoneNumber: parameters.phoneNumber,
        otpCode: parameters.code,
        verification: Verification(type: fallbackType, secret: .empty)
      )
      recoveryCodePurpose = .login(parameters: parameters, completion: completion)
    }
    
    navigation = .recoveryCode(purpose: recoveryCodePurpose)
  }
  
  func hidePopup() {
    popup = nil
  }
  
  func didContinueButtonTap() {
    switch purpose {
    case .disableMFA:
      disableMFAAuthentication()
    case let .login(parameters, _, completion):
      loginWithTOTPCode(parameters: parameters, completion: completion)
    }
  }
}

// MARK: - Private Functions
private extension EnterTOTPCodeViewModel {
  func observeTOTPInput() {
    $totpCode
      .receive(on: DispatchQueue.main)
      .sink(receiveValue: { [weak self] code in
        guard let self else {
          return
        }
        guard code.count == self.totpCodeLength else {
          self.isTOTPCodeEntered = false
          self.errorMessage = nil
          return
        }
        self.isTOTPCodeEntered = true
      })
      .store(in: &cancellable)
  }
  
  func handleError(error: Error) {
    log.error(error.userFriendlyMessage)
    
    switch error.inlineError {
    case .invalidTOTP, .verificationInvalid, .otpIncorrect:
      errorMessage = error.userFriendlyMessage
    default:
      toastMessage = error.userFriendlyMessage
    }
  }
}

// MARK: - Types
extension EnterTOTPCodeViewModel {
  enum Navigation {
    case recoveryCode(purpose: RecoveryCodePurpose)
  }
  
  enum Popup {
    case mfaTurnedOff
  }
}

public enum EnterTOTPCodePurpose {
  case disableMFA
  case login(parameters: LoginParameters, fallbackType: String, completion: (() -> Void))
  
  public static func == (lhs: EnterTOTPCodePurpose, rhs: EnterTOTPCodePurpose) -> Bool {
    switch (lhs, rhs) {
    case (.disableMFA, .disableMFA):
      return true
    case let (.login(lhsParameters, _, _), .login(rhsParameters, _, _)):
      return lhsParameters.phoneNumber == rhsParameters.phoneNumber
    default:
      return false
    }
  }
}
