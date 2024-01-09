import AccountData
import AccountDomain
import Combine
import Factory
import Foundation
import LFStyleGuide
import LFUtilities

@MainActor
public final class VerifyEmailViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.accountRepository) var accountRepository
  
  @LazyInjected(\.customerSupportService) var customerSupportService
  
  @Published var isLoading: Bool = false
  @Published var shouldPresentConfirmation: Bool = false
  @Published var toastMessage: String?
  @Published public var isOTPCodeEntered: Bool = false
  
  @Published public var generatedOTP: String = .empty
  
  let otpCodeLength = Constants.MaxCharacterLimit.otpCode.value
  
  lazy var verifyEmailRequestUseCase: VerifyEmailRequestUseCaseProtocol = {
    VerifyEmailRequestUseCase(repository: accountRepository)
  }()
  
  lazy var verifyEmailUseCase: VerifyEmailUseCaseProtocol = {
    VerifyEmailUseCase(repository: accountRepository)
  }()
  
  lazy var getUserUseCase: GetUserUseCaseProtocol = {
    GetUserUseCase(repository: accountRepository)
  }()
  
  init() {
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
      defer {
        isLoading = false
      }
      
      isLoading = true
      
      do {
        try await verifyEmailUseCase.execute(code: generatedOTP)
        let user = try await getUserUseCase.execute()
        accountDataManager.update(missingSteps: user.missingSteps)
        
        shouldPresentConfirmation = true
      } catch {
        toastMessage = error.userFriendlyMessage
        log.error(error.userFriendlyMessage)
      }
    }
  }
  
  func requestOTP() {
    Task {
      defer {
        isLoading = false
      }
      
      isLoading = true
      
      do {
        try await verifyEmailRequestUseCase.execute()
      } catch {
        toastMessage = error.userFriendlyMessage
        log.error(error.userFriendlyMessage)
      }
    }
  }
}

// MARK: - Private Functions
private extension VerifyEmailViewModel {
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
}
