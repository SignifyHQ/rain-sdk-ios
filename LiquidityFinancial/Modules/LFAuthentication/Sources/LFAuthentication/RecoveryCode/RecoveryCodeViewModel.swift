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
final class RecoveryCodeViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.onboardingRepository) var onboardingRepository
  @LazyInjected(\.customerSupportService) var customerSupportService

  @Published var recoveryCode: String = .empty
  
  @Published var isVerifying: Bool = false
  @Published var inlineErrorMessage: String?
  @Published var toastMessage: String?
  @Published var popup: Popup?
  
  let purpose: RecoveryCodePurpose
  
  lazy var disableMFAUseCase: DisableMFAUseCaseProtocol = {
    DisableMFAUseCase(repository: accountRepository)
  }()
  
  lazy var loginUseCase: LoginUseCaseProtocol = {
    LoginUseCase(repository: onboardingRepository)
  }()
  
  private var subscribers: Set<AnyCancellable> = []
  
  init(purpose: RecoveryCodePurpose) {
    self.purpose = purpose
  }
}

// MARK: - View Helpers
extension RecoveryCodeViewModel {
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }
  
  func didContinueButtonTap() {
    switch purpose {
    case let .disableMFA(completion):
      disableMFAAuthentication(completion: completion)
    case let .login(parameters, completion):
      loginWithRecoveryCode(parameters: parameters, completion: completion)
    }
  }
  
  func hidePopup() {
    popup = nil
  }
  
  func dismissAction() {
    switch popup {
    case let .mfaTurnedOff(completion):
      hidePopup()
      completion()
    default:
      break
    }
  }
}

// MARK: - APIs

extension RecoveryCodeViewModel {
  private func disableMFAAuthentication(completion: @escaping (() -> Void)) {
    Task {
      defer { isVerifying = false }
      isVerifying = true
      inlineErrorMessage = nil
      
      do {
        let response = try await disableMFAUseCase.execute(code: recoveryCode.trimWhitespacesAndNewlines())
        if response.success {
          popup = .mfaTurnedOff(completion: completion)
          accountDataManager.update(mfaEnabled: false)
        }
      } catch {
        handleError(error: error)
      }
    }
  }
  
  private func loginWithRecoveryCode(parameters: LoginParameters, completion: @escaping (() -> Void)) {
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
          verification: Verification(type: parameters.verification?.type ?? .empty, secret: recoveryCode)
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

// MARK: - Private Functions

extension RecoveryCodeViewModel {
  func handleError(error: Error) {
    log.error(error.userFriendlyMessage)
    
    switch error.inlineError {
    case .invalidTOTP, .verificationInvalid, .otpIncorrect:
      inlineErrorMessage = error.userFriendlyMessage
    default:
      toastMessage = error.userFriendlyMessage
    }
  }
}

// MARK: - Types
extension RecoveryCodeViewModel {
  enum Popup: Equatable {
    case mfaTurnedOff(completion: (() -> Void))
    
    static func == (lhs: Popup, rhs: Popup) -> Bool {
      true
    }
  }
}

public enum RecoveryCodePurpose: Equatable {
  case disableMFA(completion: (() -> Void))
  case login(parameters: LoginParameters, completion: (() -> Void))
  
  public static func == (lhs: RecoveryCodePurpose, rhs: RecoveryCodePurpose) -> Bool {
    switch (lhs, rhs) {
    case let (.login(lhsParameters, _), .login(rhsParameters, _)):
      return lhsParameters.phoneNumber == rhsParameters.phoneNumber
    default:
      return true
    }
  }
}
