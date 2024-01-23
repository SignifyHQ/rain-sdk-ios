import Foundation
import LFUtilities
import LFLocalizable
import Factory
import AccountData
import AccountDomain
import OnboardingDomain
import OnboardingData
import UIComponents
import NetSpendData

@MainActor
public final class IdentityVerificationCodeViewModel: ObservableObject {
  @LazyInjected(\.customerSupportService) var customerSupportService
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.onboardingRepository) var onboardingRepository
  @LazyInjected(\.noBankOnboardingFlowCoordinator) var onboardingFlowCoordinator

  @Published public var isDisableButton: Bool = true
  @Published public var isShowLogoutPopup: Bool = false
  @Published public var isLoading: Bool = false
  @Published public var errorMessage: String?
  @Published public var toastMessage: String?
  @Published public var ssn: String = "" {
    didSet {
      checkSSNFilled()
    }
  }
  @Published public var passport: String = "" {
    didSet {
      checkPassportFilled()
    }
  }
  
  lazy var loginUseCase: LoginUseCaseProtocol = {
    LoginUseCase(repository: onboardingRepository)
  }()
  
  public var phoneNumber: String
  public var otpCode: String
  public var kind: IdentityVerificationCodeKind
  
  public init(phoneNumber: String, otpCode: String, kind: IdentityVerificationCodeKind) {
    self.phoneNumber = phoneNumber
    self.otpCode = otpCode
    self.kind = kind
  }
}

// MARK: - API
public extension IdentityVerificationCodeViewModel {
  func login() {
    Task {
      defer { self.isLoading = false}
      self.isLoading = true
      do {
        let parameters = LoginParameters(phoneNumber: phoneNumber, otpCode: otpCode, lastID: lastId)
        
        // All crypto apps are still using the old authentication flow. The new authentication flow will be applied later.
        _ = try await loginUseCase.execute(isNewAuth: false, parameters: parameters)
        
        accountDataManager.update(phone: phoneNumber)
        accountDataManager.stored(phone: phoneNumber)
        
        await checkOnboardingState()
        
      } catch {
        handleError(error: error)
      }
    }
  }
}

// MARK: - View Helpers
public extension IdentityVerificationCodeViewModel {
  var title: String {
    switch kind {
    case .ssn:
      return L10N.Common.EnterVerificationCode.Last4SSN.screenTitle
    case .passport:
      return L10N.Common.EnterVerificationCode.Last5Passport.screenTitle
    }
  }
  
  var lastId: String {
    switch kind {
    case .ssn:
      return ssn
    case .passport:
      return passport
    }
  }
  
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }
  
  func handleError(error: Error) {
    guard let errorObject = error.asErrorObject else {
      toastMessage = error.userFriendlyMessage
      return
    }
    switch errorObject.code {
    case Constants.ErrorCode.userInactive.value:
      onboardingFlowCoordinator.set(route: .accountLocked)
    case Constants.ErrorCode.credentialsInvalid.value:
      toastMessage = L10N.Common.EnterVerificationCode.CodeInvalid.message
    case Constants.ErrorCode.invalidSSN.value:
      errorMessage = errorObject.message
    default:
      toastMessage = error.userFriendlyMessage
    }
  }
}

// MARK: - Private Functions
private extension IdentityVerificationCodeViewModel {
  func checkSSNFilled() {
    let ssnLength = ssn.trimWhitespacesAndNewlines().count
    isDisableButton = (ssnLength == 0) || (ssnLength != Constants.MaxCharacterLimit.ssnLength.value)
  }
  
  func checkPassportFilled() {
    let passportLength = passport.trimWhitespacesAndNewlines().count
    isDisableButton = (passportLength == 0) || (passportLength != Constants.MaxCharacterLimit.passportLength.value)
  }
  
  @MainActor
  func checkOnboardingState() async {
    do {
      try await onboardingFlowCoordinator.apiFetchCurrentState()
    } catch {
      log.error(error.userFriendlyMessage)
      onboardingFlowCoordinator.forcedLogout()
    }
  }
}
