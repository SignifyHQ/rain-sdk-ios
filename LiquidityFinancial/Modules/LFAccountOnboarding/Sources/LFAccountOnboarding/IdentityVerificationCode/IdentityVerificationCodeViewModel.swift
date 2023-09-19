import Foundation
import LFUtilities
import LFLocalizable
import Factory
import AccountData
import AccountDomain
import RewardData
import RewardDomain
import OnboardingDomain

@MainActor
final class IdentityVerificationCodeViewModel: ObservableObject {
  @LazyInjected(\.intercomService) var intercomService
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.rewardDataManager) var rewardDataManager
  @LazyInjected(\.onboardingRepository) var onboardingRepository
  @LazyInjected(\.onboardingFlowCoordinator) var onboardingFlowCoordinator

  @Published var isDisableButton: Bool = true
  @Published var isShowLogoutPopup: Bool = false
  @Published var isLoading: Bool = false
  @Published var errorMessage: String?
  @Published var toastMessage: String?
  @Published var ssn: String = "" {
    didSet {
      checkSSNFilled()
    }
  }
  @Published var passport: String = "" {
    didSet {
      checkPassportFilled()
    }
  }
  
  lazy var loginUseCase: LoginUseCaseProtocol = {
    LoginUseCase(repository: onboardingRepository)
  }()
  
  let phoneNumber: String
  let otpCode: String
  let kind: Kind
  
  init(phoneNumber: String, otpCode: String, kind: IdentityVerificationCodeViewModel.Kind) {
    self.phoneNumber = phoneNumber
    self.otpCode = otpCode
    self.kind = kind
  }
}

// MARK: - API
extension IdentityVerificationCodeViewModel {
  func login() {
    Task {
      defer { self.isLoading = false}
      self.isLoading = true
      do {
        _ = try await loginUseCase.execute(phoneNumber: phoneNumber, otpCode: otpCode, lastID: lastId)
        accountDataManager.update(phone: phoneNumber)
        accountDataManager.stored(phone: phoneNumber)
        
        if LFUtility.charityEnabled { // we enable showRoundUpForCause after user login
          UserDefaults.showRoundUpForCause = true
        }
        
        await checkOnboardingState()
        
      } catch {
        handleError(error: error)
      }
    }
  }
}

// MARK: - View Helpers
extension IdentityVerificationCodeViewModel {
  var title: String {
    switch kind {
    case .ssn:
      return LFLocalizable.EnterVerificationCode.Last4SSN.screenTitle
    case .passport:
      return LFLocalizable.EnterVerificationCode.Last5Passport.screenTitle
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
  
  func openIntercom() {
    intercomService.openIntercom()
  }
}

// MARK: - Private Functions
private extension IdentityVerificationCodeViewModel {
  func handleError(error: Error) {
    guard let code = error.asErrorObject?.code else {
      toastMessage = error.localizedDescription
      return
    }
    switch code {
      case Constants.ErrorCode.userInactive.value:
        onboardingFlowCoordinator.set(route: .accountLocked)
      case Constants.ErrorCode.credentialsInvalid.value:
        toastMessage = LFLocalizable.EnterVerificationCode.CodeInvalid.message
      case Constants.ErrorCode.lastXIdInvalid.value:
        toastMessage = LFLocalizable.EnterVerificationCode.LastXIdInvalid.message
      default:
        toastMessage = error.localizedDescription
    }
  }
  
  func checkSSNFilled() {
    let ssnLength = ssn.trimWhitespacesAndNewlines().count
    isDisableButton = (ssnLength == 0) || (ssnLength != Constants.MaxCharacterLimit.ssnLength.value)
  }
  
  func checkPassportFilled() {
    let passportLength = passport.trimWhitespacesAndNewlines().count
    isDisableButton = (passportLength == 0) || (passportLength != Constants.MaxCharacterLimit.passportLength.value)
  }
  
  func handleDataUser(user: LFUser) {
    accountDataManager.storeUser(user: user)
    if let rewardType = APIRewardType(rawValue: user.userRewardType ?? "") {
      rewardDataManager.update(currentSelectReward: rewardType)
    }
    if let userSelectedFundraiserID = user.userSelectedFundraiserId {
      rewardDataManager.update(selectedFundraiserID: userSelectedFundraiserID)
    }
  }
  
  @MainActor
  func checkOnboardingState() async {
    do {
      async let fetchUser = accountRepository.getUser()
      let user = try await fetchUser
      handleDataUser(user: user)
      self.onboardingFlowCoordinator.set(route: .dashboard)
    } catch {
      log.error(error.localizedDescription)
      
      if error.localizedDescription.contains("identity_verification_questions_not_available") {
        onboardingFlowCoordinator.set(route: .popTimeUp)
        return
      }
      
      onboardingFlowCoordinator.forcedLogout()
    }
  }
}

// MARK: - Types
extension IdentityVerificationCodeViewModel {
  enum Kind {
    case ssn
    case passport
  }
}
