import Foundation
import LFUtilities
import LFLocalizable
import Factory
import AccountData
import AccountDomain
import PortalDomain
import PortalData
import OnboardingDomain
import OnboardingData
import NetSpendData
import Combine
import LFFeatureFlags
import Services

@MainActor
public final class IdentityVerificationCodeViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.onboardingRepository) var onboardingRepository
  @LazyInjected(\.portalRepository) var portalRepository
  @LazyInjected(\.customerSupportService) var customerSupportService
  @LazyInjected(\.featureFlagManager) var featureFlagManager
  @LazyInjected(\.portalService) var portalService

  @Published var isDisableButton: Bool = true
  @Published var isShowLogoutPopup: Bool = false
  @Published var isLoading: Bool = false
  @Published var errorMessage: String?
  @Published var toastMessage: String?
  @Published var ssn: String = .empty
  @Published var passport: String = .empty
  
  lazy var loginUseCase: LoginUseCaseProtocol = {
    LoginUseCase(repository: onboardingRepository)
  }()
  
  lazy var registerPortalUseCase: RegisterPortalUseCaseProtocol = {
    RegisterPortalUseCase(repository: portalRepository)
  }()
  
  private let phoneNumber: String
  private let otpCode: String
  let kind: IdentityVerificationCodeKind
  
  private let handleOnboardingStep: (() async throws -> Void)?
  private let forceLogout: (() -> Void)?
  private let setRouteToAccountLocked: (() -> Void)?
  
  private var cancellables: Set<AnyCancellable> = []

  public init(
    phoneNumber: String,
    otpCode: String,
    kind: IdentityVerificationCodeKind,
    handleOnboardingStep: (() async throws -> Void)?,
    forceLogout: (() -> Void)?,
    setRouteToAccountLocked: (() -> Void)?
  ) {
    self.phoneNumber = phoneNumber
    self.otpCode = otpCode
    self.kind = kind
    self.handleOnboardingStep = handleOnboardingStep
    self.forceLogout = forceLogout
    self.setRouteToAccountLocked = setRouteToAccountLocked
    
    observeSSNInput()
    observePassportInput()
  }
}

// MARK: - APIs Handler
extension IdentityVerificationCodeViewModel {
  func login() {
    Task {
      defer { self.isLoading = false}
      self.isLoading = true
      
      do {
        /*
         All cryptocurrency applications are currently utilizing the old authentication flow.
         The implementation of the new authentication flow will be postponed until a later time.
         */
        let isNewAuth = LFUtilities.cryptoEnabled ? false : featureFlagManager.isFeatureFlagEnabled(.mfa)
        let verification = isNewAuth ? Verification(type: VerificationType.last4X.rawValue, secret: lastId) : nil
        let parameters = LoginParameters(
          phoneNumber: phoneNumber,
          otpCode: otpCode,
          lastID: isNewAuth ? nil : lastId,
          verification: verification
        )
        let response = try await loginUseCase.execute(
          isNewAuth: isNewAuth,
          parameters: parameters
        )
        
        setupPortal(portalToken: response.portalSessionToken)
        
        accountDataManager.update(phone: phoneNumber)
        accountDataManager.phoneNumber = phoneNumber
        
        await checkOnboardingState()
      } catch {
        handleError(error: error)
      }
    }
  }
  
  private func checkOnboardingState() async {
    do {
      try await handleOnboardingStep?()
    } catch {
      log.error(error.userFriendlyMessage)
      forceLogout?()
    }
  }
}

// MARK: - View Handler
extension IdentityVerificationCodeViewModel {
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
}

// MARK: - Private Functions
private extension IdentityVerificationCodeViewModel {
  func observeSSNInput() {
    $ssn
      .receive(on: DispatchQueue.main)
      .sink(
        receiveCompletion: { _ in },
        receiveValue: { [weak self] ssn in
          guard let self else { return }
          
          let ssnLength = ssn.trimWhitespacesAndNewlines().count
          self.isDisableButton = ssnLength != Constants.MaxCharacterLimit.ssnLength.value
        }
      )
      .store(in: &cancellables)
  }
  
  func observePassportInput() {
    $passport
      .receive(on: DispatchQueue.main)
      .sink(
        receiveCompletion: { _ in },
        receiveValue: { [weak self] passport in
          guard let self else { return }
          
          let passportLength = passport.trimWhitespacesAndNewlines().count
          isDisableButton = passportLength != Constants.MaxCharacterLimit.passportLength.value
        }
      )
      .store(in: &cancellables)
  }
  
  func handleError(error: Error) {
    guard let errorObject = error.asErrorObject else {
      toastMessage = error.userFriendlyMessage
      return
    }
    
    switch errorObject.code {
    case Constants.ErrorCode.userInactive.value:
      setRouteToAccountLocked?()
    case Constants.ErrorCode.credentialsInvalid.value:
      toastMessage = L10N.Common.EnterVerificationCode.CodeInvalid.message
    case Constants.ErrorCode.invalidSSN.value:
      errorMessage = errorObject.message
    default:
      toastMessage = errorObject.message
    }
  }
  
  func setupPortal(portalToken: String?) {
    guard let portalToken else { return }
    
    Task {
      do {
        try await registerPortalUseCase.execute(portalToken: portalToken)
      } catch {
        handlePortalError(error: error)
      }
    }
  }
  
  func handlePortalError(error: Error) {
    guard let portalError = error as? LFPortalError else {
      toastMessage = error.userFriendlyMessage
      log.error(error.userFriendlyMessage)
      return
    }
    
    switch portalError {
    case .customError(let message):
      toastMessage = message
    default:
      toastMessage = portalError.localizedDescription
    }
    
    log.error(toastMessage ?? portalError.localizedDescription)
  }
}
