import AccountData
import AccountDomain
import Factory
import Foundation
import LFUtilities
import PortalData
import PortalDomain
import RainData
import RainDomain

// MARK: - Dependency Injection
extension Container {
  public var onboardingCoordinator: Factory<OnboardingCoordinatorProtocol> {
    self {
      OnboardingCoordinator()
    }
    .singleton
  }
}

// MARK: - OnboardingCoordinatorProtocol
public protocol OnboardingCoordinatorProtocol {
  func getOnboardingNavigation() async throws -> OnboardingNavigation?
  func getUserReviewStatus() async throws -> (enum: AccountDomain.AccountReviewStatus?, rawValue: String?)
  func forceLogout()
}

public class OnboardingCoordinator: OnboardingCoordinatorProtocol {
  @LazyInjected(\.analyticsService) var analyticsService
  
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
  
  @LazyInjected(\.rainRepository) var rainRepository
  // TODO(Volo): - Below coordinator is used temproarily to set the root view,
  // it will be merged into this one later
  @LazyInjected(\.rainOnboardingFlowCoordinator) var rainOnboardingFlowCoordinator
  
  @LazyInjected(\.portalStorage) var portalStorage
  @LazyInjected(\.portalRepository) var portalRepository
  @LazyInjected(\.portalService) var portalService
  
  lazy var getOnboardingMissingSteps: RainGetOnboardingMissingStepsUseCaseProtocol = {
    RainGetOnboardingMissingStepsUseCase(repository: rainRepository)
  }()
  
  lazy var getUserUseCase: GetUserUseCaseProtocol = {
    GetUserUseCase(repository: accountRepository)
  }()
  
  lazy var refreshPortalAssetsUseCase: RefreshPortalAssetsUseCaseProtocol = {
    RefreshPortalAssetsUseCase(repository: portalRepository, storage: portalStorage)
  }()
  
  public func getOnboardingNavigation(
  ) async throws -> OnboardingNavigation? {
    // Fetch the missing steps
    let response = try await getOnboardingMissingSteps.execute()
    // Map the missing steps to known cases
    let missingSteps = response.processSteps.compactMap {
      OnboardingMissingStep(rawValue: $0)
    }
    // Check if there are missing steps for the user
    guard !missingSteps.isEmpty
    else {
      // If there are no missing steps, get user's KYC status
      let navigation = try await getNavigationFromReviewStatus()
      // Get user object in order to determine the US/International flow based
      // on the country code if the navigation points to accept terms screen only
      if case .acceptTerms = navigation {
        let user = try await getUserUseCase.execute()
        accountDataManager.storeUser(user: user)
      }
      
      return navigation
    }
    
    let navigation = handleOnboardingMissingSteps(from: missingSteps)
    // Get user object in order to determine the US/International flow based
    // on the country code if the navigation points to accept terms screen only
    if case .acceptTerms = navigation {
      let user = try await getUserUseCase.execute()
      accountDataManager.storeUser(user: user)
    }
    
    return navigation
  }
  
  public func getUserReviewStatus(
  ) async throws -> (enum: AccountDomain.AccountReviewStatus?, rawValue: String?) {
    // Get the user object from the backend and store on device
    let user = try await getUserUseCase.execute()
    storeUserData(user: user)
    // Map the review status and return enum along with war string
    return (enum: user.accountReviewStatusEnum, rawValue: user.accountReviewStatus)
  }
  
  public func forceLogout() {
    rainOnboardingFlowCoordinator.forceLogout()
  }
}

//MARK: - Private Methods
extension OnboardingCoordinator {
  private func getNavigationFromReviewStatus(
  ) async throws -> OnboardingNavigation? {
    // Get the user review status
    let accountReviewStatus = try await getUserReviewStatus()
    // Check the review status
    guard let accountReviewStatus = accountReviewStatus.enum
    else {
      // Handle the unknown review status
      return handleUnclearAccountReviewStatus(reviewStatus: accountReviewStatus.rawValue)
    }
    // Handle the review status and perform corresponding navigation
    switch accountReviewStatus {
    case .approved:
      return try await handleOnboardingCompletion()
    case .rejected:
      return .accountRejected
    case .inreview, .reviewing:
      return .accountInReview
    }
  }
  
  private func handleOnboardingCompletion(
  ) async throws -> OnboardingNavigation? {
    // Calling portal balance refresh to check if the session needs to be refreshed
    do {
      try await refreshPortalAssetsUseCase.execute()
    } catch {
      log.error("Failed to refresh portal assets: \(error)")
    }
    // Check if the wallet is on device
    let isWalletOnDevice = await portalService.isWalletOnDevice()
    log.info("Portal Swift: Is wallet on device: \(isWalletOnDevice)")
    // If yes, take the user to home screen
    if isWalletOnDevice {
      rainOnboardingFlowCoordinator.set(route: .dashboard)
      return nil
      // Otherwise, take the user to wallet recovery flow
    } else {
      return .recoverPortalWallet
    }
  }
  
  private func handleOnboardingMissingSteps(
    from steps: [OnboardingMissingStep]
  ) -> OnboardingNavigation? {
    if steps.contains(.shouldCreatePortalWallet) {
      return .createPortalWallet
    } else if steps.contains(.shouldSetPortalWalletPin) {
      return .setPortalWalletPin
    } else if steps.contains(.shouldCreateRainUser) {
      return .createRainUser
    } else if steps.contains(.informationRequired) {
      return .informationRequired
    } else if steps.contains(.verificationRequired) {
      return .verificationRequired
    } else if steps.contains(.isBlocked) {
      return .accountRejected
    } else if steps.contains(.shouldAcceptTerms) {
      return .acceptTerms
    }
    
    return nil
  }
  
  private func handleUnclearAccountReviewStatus(
    reviewStatus: String?
  ) -> OnboardingNavigation  {
    // There is data returned for review status but it does not match known values
    let description = Constants
      .DebugLog
      .missingAccountStatus(
        status: String(describing: reviewStatus)
      )
      .value
    
    return .unclearStatus(description)
  }
  
  private func storeUserData(
    user: LFUser
  ) {
    accountDataManager.storeUser(user: user)
    accountDataManager.userNameDisplay = user.firstName ?? ""
    
    trackUserInformation(user: user)
  }
  
  private func trackUserInformation(
    user: LFUser
  ) {
    guard let userModel = user as? APIUser,
          let data = try? JSONEncoder().encode(userModel)
    else {
      return
    }
    
    let dictionary = (
      try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
    ).flatMap { $0 as? [String: Any] }
    
    var values = dictionary ?? [:]
    values["birthday"] = LiquidityDateFormatter.simpleDate.parseToDate(from: userModel.dateOfBirth ?? "")
    values["avatar"] = userModel.profileImage ?? ""
    values["idNumber"] = "REDACTED"
    
    analyticsService.set(params: values)
  }
}
