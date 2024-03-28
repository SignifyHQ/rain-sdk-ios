import SwiftUI
import LFUtilities
import Combine
import Factory
import NetSpendData
import NetspendDomain
import OnboardingData
import AccountData
import AccountDomain
import OnboardingDomain
import LFStyleGuide
import LFLocalizable
import Services
import BaseOnboarding
import LFFeatureFlags

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
  func apiFetchCurrentState() async
  func handleOnboardingStep() async throws
  func forceLogout()
}

// MARK: - RainOnboardingFlowCoordinator
public class RainOnboardingFlowCoordinator: OnboardingFlowCoordinatorProtocol {
  @LazyInjected(\.authorizationManager) var authorizationManager
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.featureFlagManager) var featureFlagManager
  
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.onboardingRepository) var onboardingRepository
  
  @LazyInjected(\.pushNotificationService) var pushNotificationService
  @LazyInjected(\.analyticsService) var analyticsService
  
  lazy var accountUseCase: AccountUseCaseProtocol = {
    AccountUseCase(repository: accountRepository)
  }()
  
  public let routeSubject: CurrentValueSubject<Route, Never>
  
  public var accountFeatureConfigData = AccountFeatureConfigData(configJSON: "", isLoading: false)
  
  public init() {
    self.routeSubject = .init(.initial)
  }
}

// MARK: - Public Functions
public extension RainOnboardingFlowCoordinator {
  func set(route: Route) {
    log.info("OnboardingFlowCoordinator route: \(route), with current route: \(routeSubject.value)")
    routeSubject.send(route)
  }
  
  func routeUser() {
    Task { @MainActor in
#if DEBUG
      let start = CFAbsoluteTimeGetCurrent()
#endif
      await apiFetchFetureConfig()
      
      if let model = checkForForceUpdateApp() {
        set(route: .forceUpdate(model))
        return
      }
      
      if checkUserIsValid() {
        await apiFetchCurrentState()
      } else {
        log.info("<<<<<<<<<<<<<< The user changes phone login to the device >>>>>>>>>>>>>>>")
        forceLogout()
      }
#if DEBUG
      let diff = CFAbsoluteTimeGetCurrent() - start
      log.debug("Took \(diff) seconds")
#endif
    }
  }

  func apiFetchCurrentState() async {
    do {
      guard authorizationManager.isTokenValid() else {
        try await authorizationManager.refreshToken()
        try await apiFetchAndUpdateForStart()
        return
      }
      
      try await apiFetchAndUpdateForStart()
    } catch {
      log.error(error.userFriendlyMessage)
      guard error.userFriendlyMessage.contains(Constants.ErrorCode.questionsNotAvailable.value) else {
        forceLogout()
        return
      }
      
      set(route: .popTimeUp)
    }
  }
  
  func handleOnboardingStep() async throws {
    /*
        1. Get onboarding missing steps.
        2. If there are no remaining onboarding steps to complete, it proceeds to fetch the rain status.
        3. If there are remaining onboarding steps, it processes each step and takes appropriate actions.
     */
  }
  
  func forceLogout() {
    clearUserData()
    set(route: .phone)
  }
}

// MARK: - Private Functions
private extension RainOnboardingFlowCoordinator {
  func checkUserIsValid() -> Bool {
    accountDataManager.sessionID.isEmpty == false
  }
  
  func apiFetchAndUpdateForStart() async throws {
    guard accountDataManager.userCompleteOnboarding else {
      try await handleOnboardingStep()
      return
    }
    
    set(route: .dashboard)
  }
  
  func fetchUserReviewStatus() async throws {
    let user = try await accountRepository.getUser()
    
    guard let accountReviewStatus = user.accountReviewStatusEnum else {
      if let accountReviewStatus = user.accountReviewStatus {
        let description = "Account status missing the information: \(String(describing: accountReviewStatus))"
        set(route: .unclear(description))
      }
      handleDataUser(user: user)
      return
    }
    
    switch accountReviewStatus {
    case .approved:
      // TODO: Fetch Rain Status
      print("TODO: Fetch Rain Status")
    case .rejected:
      set(route: .accountReject)
    case .inreview, .reviewing:
      set(route: .kycReview)
    }
    
    handleDataUser(user: user)
  }
  
  func handleDataUser(user: LFUser) {
    accountDataManager.storeUser(user: user)
    trackUserInformation(user: user)
  }
  
  func trackUserInformation(user: LFUser) {
    guard let userModel = user as? APIUser else { return }
    guard let data = try? JSONEncoder().encode(userModel) else { return }
    let dictionary = (try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)).flatMap { $0 as? [String: Any] }
    var values = dictionary ?? [:]
    values["birthday"] = LiquidityDateFormatter.simpleDate.parseToDate(from: userModel.dateOfBirth ?? "")
    values["avatar"] = userModel.profileImage ?? ""
    values["idNumber"] = "REDACTED"
    analyticsService.set(params: values)
  }
  
  func clearUserData() {
    log.info("<<<<<<<<<<<<<< 401 Unauthorized: Clear user data and perform logout. >>>>>>>>>>>>>>>")
    accountDataManager.clearUserSession()
    authorizationManager.clearToken()
    pushNotificationService.signOut()
    featureFlagManager.signOut()
  }
  
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
  
  func apiFetchFetureConfig() async {
    do {
      defer { accountFeatureConfigData.isLoading = false }
      accountFeatureConfigData.isLoading = true
      
      let entity = try await accountUseCase.getFeatureConfig()
      accountFeatureConfigData.configJSON = entity.config ?? ""
      accountDataManager.featureConfig = accountFeatureConfigData.featureConfig
    } catch {
      log.error(error.userFriendlyMessage)
    }
  }
}

// MARK: - Types
public extension RainOnboardingFlowCoordinator {
  enum Route: Hashable, Identifiable {
    case initial
    case phone
    case accountLocked
    case welcome
    case kycReview
    case dashboard
    case information
    case accountReject
    case unclear(String)
    case popTimeUp
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
