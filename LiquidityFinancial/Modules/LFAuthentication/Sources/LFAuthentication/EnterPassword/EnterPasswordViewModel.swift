import AccountData
import AccountDomain
import OnboardingDomain
import OnboardingData
import Foundation
import LFUtilities
import LFLocalizable
import LFStyleGuide
import Factory
import Services
import LFFeatureFlags
import Combine

@MainActor
public final class EnterPasswordViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.onboardingRepository) var onboardingRepository

  @LazyInjected(\.customerSupportService) var customerSupportService
  @LazyInjected(\.featureFlagManager) var featureFlagManager
  
  @Published var navigation: Navigation?
  @Published var shouldDismissFlow: Bool?
  
  @Published var isLoading: Bool = false
  @Published var toastMessage: String?
  @Published var inlineErrorMessage: String?
  
  @Published var password: String = ""
  
  @Published var isDisableContinueButton: Bool = true
  
  var purpose: EnterPasswordPurpose
  
  lazy var loginWithPasswordUseCase: PasswordLoginUseCaseProtocol = {
    PasswordLoginUseCase(repository: accountRepository, dataManager: accountDataManager)
  }()
  
  lazy var loginUseCase: LoginUseCaseProtocol = {
    LoginUseCase(repository: onboardingRepository)
  }()
  
  private var subscribers: Set<AnyCancellable> = []

  init(purpose: EnterPasswordPurpose) {
    self.purpose = purpose
    observePasswordInput()
  }
}

// MARK: - API
extension EnterPasswordViewModel {
  func handleLoginToProlongSession() {
    Task {
      defer { isLoading = false }
      
      isLoading = true
      inlineErrorMessage = nil
      
      do {
        _ = try await loginWithPasswordUseCase.execute(password: password)
        
        switch purpose {
        case .changePassword:
          navigation = .changePassword
        case .biometricsFallback:
          shouldDismissFlow = true
        default:
          break
        }
      } catch {
        handleError(error: error)
      }
    }
  }
  
  func handleLoginToInitSession(parameters: LoginParameters, completion: @escaping (() -> Void)) {
    Task {
      isLoading = true
      inlineErrorMessage = nil

      NotificationCenter.default
        .publisher(for: .didLoginComplete)
        .sink { [weak self] _ in
          guard let self else {
            return
          }
          self.isLoading = false
        }
        .store(in: &subscribers)
      
      do {
        let parameters = LoginParameters(
          phoneNumber: parameters.phoneNumber,
          otpCode: parameters.code,
          verification: Verification(type: parameters.verification?.type ?? .empty, secret: password)
        )
        _ = try await loginUseCase.execute(
          isNewAuth: featureFlagManager.isFeatureFlagEnabled(.mfa),
          parameters: parameters
        )
        completion()
      } catch {
        isLoading = false
        handleError(error: error)
      }
    }
  }
}
  
// MARK: - View Helpers
extension EnterPasswordViewModel {
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }
  
  func didTapContinueButton() {
    switch purpose {
    case let .login(parameters, completion):
      handleLoginToInitSession(parameters: parameters, completion: completion)
    case .changePassword, .biometricsFallback:
      handleLoginToProlongSession()
    }
  }
  
  func didTapForgotPasswordButton() {
    switch purpose {
    case .biometricsFallback, .changePassword:
      navigation = .recoverPassword(
        purpose: .resetPassword
      )
    case let .login(parameters, _):
      navigation = .recoverPassword(
        purpose: .login(phoneNumber: parameters.phoneNumber)
      )
    }
  }
}

// MARK: - Private Functions
private extension EnterPasswordViewModel {
  func observePasswordInput() {
    $password
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: { _ in
      }, receiveValue: { [weak self] passwordString in
        guard let self else { return }
        self.inlineErrorMessage = nil
        self.isDisableContinueButton = passwordString.trimWhitespacesAndNewlines().isEmpty
      })
      .store(in: &subscribers)
  }
  
  func handleError(error: Error) {
    log.error(error.userFriendlyMessage)

    switch error.inlineError {
    case .invalidCredentials, .verificationInvalid:
      inlineErrorMessage = L10N.Common.Authentication.EnterPassword.Error.wrongPassword
    case .otpIncorrect:
      inlineErrorMessage = error.userFriendlyMessage
    default:
      toastMessage = error.userFriendlyMessage
    }
  }
}

// MARK: - Enums

extension EnterPasswordViewModel {
  enum Navigation {
    case recoverPassword(purpose: ResetPasswordPurpose)
    case changePassword
  }
}

public enum EnterPasswordPurpose: Equatable {
  case biometricsFallback
  case changePassword
  case login(parameters: LoginParameters, completion: (() -> Void))
  
  public static func == (lhs: EnterPasswordPurpose, rhs: EnterPasswordPurpose) -> Bool {
    switch (lhs, rhs) {
    case (.biometricsFallback, .biometricsFallback), (.changePassword, .changePassword):
      return true
    case let (.login(lhsParameters, _), .login(rhsParameters, _)):
      return lhsParameters.phoneNumber == rhsParameters.phoneNumber
    default:
      return false
    }
  }
}
