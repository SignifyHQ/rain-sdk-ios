import AccountData
import AccountDomain
import Combine
import Factory
import Foundation
import LFStyleGuide
import LFUtilities

@MainActor
public final class ResetPasswordViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.accountRepository) var accountRepository
  
  @LazyInjected(\.customerSupportService) var customerSupportService
  
  @Published var navigation: Navigation?
  
  @Published var isLoading: Bool = false
  @Published var toastMessage: String?
  @Published public var isOTPCodeEntered: Bool = false
  @Published public var generatedOTP: String = .empty
  
  let purpose: ResetPasswordPurpose
  let otpCodeLength = Constants.MaxCharacterLimit.otpCode.value
  
  lazy var resetPasswordRequestUseCase: ResetPasswordRequestUseCaseProtocol = {
    ResetPasswordRequestUseCase(repository: accountRepository)
  }()
  
  lazy var resetPasswordVerifyUseCase: ResetPasswordVerifyUseCaseProtocol = {
    ResetPasswordVerifyUseCase(repository: accountRepository)
  }()
  
  init(purpose: ResetPasswordPurpose) {
    self.purpose = purpose
    observeOTPInput()
  }
  
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }
  
  func didTapResendCodeButton() {
    requestOTP()
  }
  
  func didTapContinueButton() {
    Task {
      defer { isLoading = false }
      isLoading = true
      
      do {
        let phoneNumber = getPhoneNumber()
        let response = try await resetPasswordVerifyUseCase.execute(phoneNumber: phoneNumber, code: generatedOTP)
        navigation = .resetPassword(
          purpose: .resetPassword(token: response.token, phoneNumber: phoneNumber)
        )
      } catch {
        handleError(error: error)
      }
    }
  }
  
  func requestOTP() {
    Task {
      defer { isLoading = false }
      isLoading = true
      
      do {
        let phoneNumber = getPhoneNumber()
        try await resetPasswordRequestUseCase.execute(phoneNumber: phoneNumber)
      } catch {
        handleError(error: error)
      }
    }
  }
}

// MARK: - Enums

extension ResetPasswordViewModel {
  enum Navigation {
    case resetPassword(purpose: CreatePasswordPurpose)
  }
}

public enum ResetPasswordPurpose: Equatable {
  case resetPassword
  case login(phoneNumber: String)
  
  public static func == (lhs: ResetPasswordPurpose, rhs: ResetPasswordPurpose) -> Bool {
    switch (lhs, rhs) {
    case (.resetPassword, .resetPassword):
      return true
    case let (.login(lhsphoneNumber), .login(rhsphoneNumber)):
      return lhsphoneNumber == rhsphoneNumber
    default:
      return false
    }
  }
}

// MARK: - Private Functions
private extension ResetPasswordViewModel {
  func observeOTPInput() {
    $generatedOTP
      .map { [weak self] otp in
        guard let self else {
          return false
        }
        return otp.count == self.otpCodeLength
      }
      .assign(to: &$isOTPCodeEntered)
  }
  
  func handleError(error: Error) {
    toastMessage = error.userFriendlyMessage
    log.error(error.userFriendlyMessage)
  }
  
  func getPhoneNumber() -> String {
    switch purpose {
    case .resetPassword:
      return accountDataManager.phoneNumber
    case let .login(phoneNumber):
      return phoneNumber
    }
  }
}
