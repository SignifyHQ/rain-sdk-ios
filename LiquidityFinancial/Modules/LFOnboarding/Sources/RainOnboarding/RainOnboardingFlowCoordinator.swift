import SwiftUI
import LFUtilities
import Combine
import Factory
import RainData
import RainDomain
import OnboardingData
import AccountData
import AccountDomain
import OnboardingDomain
import LFStyleGuide
import LFLocalizable
import Services
import BaseOnboarding
import LFFeatureFlags
import PortalDomain

// MARK: - DIContainer
extension Container {
  public var rainOnboardingFlowCoordinator: Factory<OnboardingFlowCoordinatorProtocol> {
    self {
      RainOnboardingFlowCoordinator()
    }.singleton
  }
}

// MARK: - OnboardingFlowCoordinatorProtocol
public protocol OnboardingFlowCoordinatorProtocol {
  var routeSubject: CurrentValueSubject<RainOnboardingFlowCoordinator.Route, Never> { get }
  func routeUser()
  func set(route: RainOnboardingFlowCoordinator.Route)
  func fetchCurrentState() async
  func fetchOnboardingMissingSteps() async throws
  func shouldProceedWithOnboarding() async throws -> Bool
  func fetchUserReviewStatus() async throws
  func forceLogout()
}

// MARK: - RainOnboardingFlowCoordinator
public class RainOnboardingFlowCoordinator: OnboardingFlowCoordinatorProtocol {
  @LazyInjected(\.authorizationManager) var authorizationManager
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.featureFlagManager) var featureFlagManager
  
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.onboardingRepository) var onboardingRepository
  @LazyInjected(\.rainRepository) var rainRepository
  
  @LazyInjected(\.portalStorage) var portalStorage
  @LazyInjected(\.portalRepository) var portalRepository
  
  @LazyInjected(\.pushNotificationService) var pushNotificationService
  @LazyInjected(\.analyticsService) var analyticsService
  @LazyInjected(\.portalService) var portalService
  
  lazy var accountUseCase: AccountUseCaseProtocol = {
    AccountUseCase(repository: accountRepository)
  }()
  
  lazy var getOnboardingMissingSteps: RainGetOnboardingMissingStepsUseCaseProtocol = {
    RainGetOnboardingMissingStepsUseCase(repository: rainRepository)
  }()
  
  lazy var getUserUseCase: GetUserUseCaseProtocol = {
    GetUserUseCase(repository: accountRepository)
  }()
  
  lazy var refreshPortalAssetsUseCase: RefreshPortalAssetsUseCaseProtocol = {
    RefreshPortalAssetsUseCase(repository: portalRepository, storage: portalStorage)
  }()
  
  public let routeSubject: CurrentValueSubject<Route, Never>
  
  public var accountFeatureConfigData = AccountFeatureConfigData(configJSON: "", isLoading: false)
  
  public init() {
    self.routeSubject = .init(.initial)
  }
}

// MARK: - Protocol API Functions
public extension RainOnboardingFlowCoordinator {
  func fetchCurrentState() async {
    do {
      guard authorizationManager.isTokenValid() else {
        try await authorizationManager.refreshToken()
        try await fetchAndUpdateForStart()
        return
      }
      
      try await fetchAndUpdateForStart()
    } catch {
      log.error(error.userFriendlyMessage)
      forceLogout()
    }
  }
  
  func fetchOnboardingMissingSteps() async throws {
    let missingSteps = try await getOnboardingMissingSteps.execute()
    let processSteps = missingSteps.processSteps
    
    guard !processSteps.isEmpty else {
      // If there are no remaining onboarding steps to complete, it proceeds to fetch the account review status.
      try await fetchUserReviewStatus()
      return
    }
    
    let steps = processSteps.compactMap {
      RainOnboardingMissingSteps(rawValue: $0)
    }
    
    guard !steps.isEmpty else {
      handleOnboardingCompletion()
      return
    }
    
    handleOnboardingMissingSteps(from: steps)
  }
  
  // Currently, this method is used to determine whether the user should be taken to the dashboard after creating a wallet (migration)
  func shouldProceedWithOnboarding() async throws -> Bool {
    let missingSteps = try await getOnboardingMissingSteps.execute()
    let steps = missingSteps.processSteps.compactMap {
      RainOnboardingMissingSteps(rawValue: $0)
    }
    
    // If there are no remaining steps, we should take the user to the dashboard and skip the rest of the onboarding steps
    if steps.isEmpty {
      set(route: .dashboard)
      
      return false
    }
    
    // If there are still steps remaining, we return true so view model knows that it needs to proceed with onboarding normally
    return true
  }
  
  func fetchUserReviewStatus() async throws {
    let user = try await getUserUseCase.execute()
    handleDataUser(user: user)

    guard let accountReviewStatus = user.accountReviewStatusEnum else {
      handleUnclearAccountReviewStatus(user: user)
      return
    }
    
    switch accountReviewStatus {
    case .approved:
      handleOnboardingCompletion()
    case .rejected:
      set(route: .accountReject)
    case .inreview, .reviewing:
      set(route: .accountInReview)
    }
  }
}

// MARK: - Protocol Functions
public extension RainOnboardingFlowCoordinator {
  func set(route: Route) {
    log.info(
      Constants.DebugLog.setRoute(fromRoute: route.id, toRoute: routeSubject.value.id).value
    )
    routeSubject.send(route)
  }
  
  func routeUser() {
    Task { @MainActor in
      #if DEBUG
      let start = CFAbsoluteTimeGetCurrent()
      #endif
      
      await fetchFetureConfig()
      
      if let model = checkForForceUpdateApp() {
        set(route: .forceUpdate(model))
        return
      }
      
      if checkUserIsValid() {
        await fetchCurrentState()
      } else {
        log.info(Constants.DebugLog.switchPhone.value)
        forceLogout()
      }
      
      #if DEBUG
      let diff = CFAbsoluteTimeGetCurrent() - start
      log.debug(Constants.DebugLog.takeTime(time: diff).value)
      #endif
    }
  }
  
  func forceLogout() {
    clearUserData()
    set(route: .phone)
  }
}

// MARK: - Private API Functions
private extension RainOnboardingFlowCoordinator {
  func fetchAndUpdateForStart() async throws {
    guard accountDataManager.userCompleteOnboarding else {
      try await fetchOnboardingMissingSteps()
      return
    }
    
    handleOnboardingCompletion()
  }
  
  func fetchFetureConfig() async {
    do {
      defer { accountFeatureConfigData.isLoading = false }
      accountFeatureConfigData.isLoading = true
      
      let entity = try await accountUseCase.getFeatureConfig()
      accountFeatureConfigData.configJSON = entity.config ?? .empty
      accountDataManager.featureConfig = accountFeatureConfigData.featureConfig
    } catch {
      log.error(error.userFriendlyMessage)
    }
  }
}

// MARK: - Private Functions
private extension RainOnboardingFlowCoordinator {
  @discardableResult
  func checkForForceUpdateApp() -> FeatureConfigModel? {
    guard let configModel = accountFeatureConfigData.featureConfig else {
      return nil
    }
    
    let checkMarketingAgainstMinimumVersion = LFUtilities.marketingVersion.compare(
      configModel.minVersionString, options: .numeric
    )
    guard checkMarketingAgainstMinimumVersion == .orderedAscending else {
      return nil
    }
    
    return configModel
  }
  
  func handleOnboardingCompletion() {
    Task {
      // Calling portal balance refresh to check if the session needs to be refreshed
      do {
        try await refreshPortalAssetsUseCase.execute()
      } catch {
        log.error("Failed to refresh portal assets: \(error)")
      }
      
      let isWalletOnDevice = await portalService.isWalletOnDevice()
      log.info("Portal Swift: Is wallet on device: \(isWalletOnDevice)")
      
      if isWalletOnDevice {
        set(route: .dashboard)
      } else {
        set(route: .recoverWallet)
      }
    }
  }
  
  func handleDataUser(user: LFUser) {
    accountDataManager.storeUser(user: user)
    accountDataManager.userNameDisplay = user.firstName ?? ""
    trackUserInformation(user: user)
  }
  
  func trackUserInformation(user: LFUser) {
    guard let userModel = user as? APIUser,
          let data = try? JSONEncoder().encode(userModel) else {
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
  
  func clearUserData() {
    log.info(Constants.DebugLog.unauthorized.value)
    accountDataManager.clearUserSession()
    authorizationManager.clearToken()
    pushNotificationService.signOut()
    featureFlagManager.signOut()
  }
  
  func handleOnboardingMissingSteps(from steps: [RainOnboardingMissingSteps]) {
    if steps.contains(.createPortalWallet) {
      set(route: .createWallet)
    } else if steps.contains(.createRainUser) {
      set(route: .personalInformation)
    } else if steps.contains(.needsInformation) {
      set(route: .missingInformation)
    } else if steps.contains(.needsVerification) {
      set(route: .identifyVerification)
    }
  }
  
  func handleUnclearAccountReviewStatus(user: LFUser) {
    guard let reviewStatus = user.accountReviewStatus else {
      return
    }
    
    // There is data returned but does not match specific values
    let description = Constants.DebugLog.missingAccountStatus(
      status: String(describing: reviewStatus)
    ).value
    set(route: .unclear(description))
  }
  
  func checkUserIsValid() -> Bool {
    !accountDataManager.phoneNumber.isEmpty
  }
}

// MARK: - Types
public extension RainOnboardingFlowCoordinator {
  enum Route: Hashable, Identifiable {
    case initial
    case phone
    case createWallet
    case personalInformation
    case accountInReview
    case dashboard
    case missingInformation
    case identifyVerification
    case accountLocked
    case accountReject
    case recoverWallet
    case unclear(String)
    case forceUpdate(FeatureConfigModel)
    
    public var id: String {
      String(describing: self)
    }
    
    public func hash(into hasher: inout Hasher) {
      hasher.combine(id)
    }
    
    public static func == (
      lhs: RainOnboardingFlowCoordinator.Route, rhs: RainOnboardingFlowCoordinator.Route
    ) -> Bool {
      lhs.hashValue == rhs.hashValue
    }
  }
}
