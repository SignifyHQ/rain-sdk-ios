import SwiftUI
import LFUtilities
import Combine
import Factory
import OnboardingData
import AccountData
import AccountDomain
import OnboardingDomain
import LFRewards
import RewardData
import RewardDomain
import LFStyleGuide
import LFLocalizable
import Services
import BaseOnboarding

extension Container {
  public var solidOnboardingFlowCoordinator: Factory<SolidOnboardingFlowCoordinatorProtocol> {
    self {
      SolidOnboardingFlowCoordinator()
    }.singleton
  }
}

public protocol SolidOnboardingFlowCoordinatorProtocol {
  var routeSubject: CurrentValueSubject<SolidOnboardingFlowCoordinator.Route, Never> { get }
  func routeUser()
  func set(route: SolidOnboardingFlowCoordinator.Route)
  func apiFetchCurrentState() async
  func handlerOnboardingStep() async throws
  func fetchUserReviewStatus() async throws
  func forcedLogout()
}

public class SolidOnboardingFlowCoordinator: SolidOnboardingFlowCoordinatorProtocol {
  
  public enum Route: Hashable, Identifiable {
    
    public static func == (lhs: SolidOnboardingFlowCoordinator.Route, rhs: SolidOnboardingFlowCoordinator.Route) -> Bool {
      return lhs.hashValue == rhs.hashValue
    }
    
    case initial
    case phone
    case accountLocked
    case selecteReward
    case kycReview
    case dashboard
    case yourAccount
    case information
    case accountReject
    case unclear(String)
    case forceUpdate(FeatureConfigModel)
    case accountMigration
    
    public var id: String {
      String(describing: self)
    }
    
    public func hash(into hasher: inout Hasher) {
      hasher.combine(id)
    }
  }
  
  @LazyInjected(\.authorizationManager) var authorizationManager
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.onboardingRepository) var onboardingRepository
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.rewardDataManager) var rewardDataManager
  @LazyInjected(\.pushNotificationService) var pushNotificationService
  @LazyInjected(\.analyticsService) var analyticsService
  @LazyInjected(\.solidOnboardingRepository) var solidOnboardingRepository
  
  lazy var accountUseCase: AccountUseCaseProtocol = {
    AccountUseCase(repository: accountRepository)
  }()
  
  lazy var getMigrationStatusUseCase: GetMigrationStatusUseCaseProtocol = {
    GetMigrationStatusUseCase(repository: accountRepository)
  }()
  
  public let routeSubject: CurrentValueSubject<Route, Never>
  
  private var subscribers: Set<AnyCancellable> = []
  
  public var accountFeatureConfigData = AccountFeatureConfigData(configJSON: "", isLoading: false)
  
  public init() {
    self.routeSubject = .init(.initial)
    NotificationCenter.default.publisher(for: .selectedReward)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] notification in
        guard let userInfo = notification.userInfo, let route = userInfo["route"] as? RewardFlowRoute else { return }
        self?.handlerRewardRoute(route: route)
      }
      .store(in: &subscribers)
  }
  
  public func set(route: Route) {
    log.info("OnboardingFlowCoordinator route: \(route), with current route: \(routeSubject.value)")
    routeSubject.send(route)
  }
  
  public func routeUser() {
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
        log.info("<<<<<<<<<<<<<< User change phone login to device >>>>>>>>>>>>>>>")
        forcedLogout()
      }
#if DEBUG
      let diff = CFAbsoluteTimeGetCurrent() - start
      log.debug("Took \(diff) seconds")
#endif
    }
  }
  
  @discardableResult
  private func checkForForceUpdateApp() -> FeatureConfigModel? {
    guard let configModel = accountFeatureConfigData.featureConfig else {
      return nil
    }
    let needsForceUpgrade = LFUtilities.marketingVersion.compare(configModel.minVersionString, options: .numeric) == .orderedAscending
    if needsForceUpgrade {
      return configModel
    }
    return nil
  }
  
  private func apiFetchFetureConfig() async {
    do {
      defer { accountFeatureConfigData.isLoading = false }
      accountFeatureConfigData.isLoading = true
      let entity = try await accountUseCase.getFeatureConfig()
      accountFeatureConfigData.configJSON = entity.config ?? ""
    } catch {
      log.error(error.localizedDescription)
    }
  }
  
  func handlerRewardRoute(route: RewardFlowRoute) {
    switch route {
    case .yourAccount:
      set(route: .yourAccount)
    case .selectReward:
      break //do not thing
    }
  }
  
  public func apiFetchCurrentState() async {
    do {
      if authorizationManager.isTokenValid() {
        try await apiFetchAndUpdateForStart()
      } else {
        try await authorizationManager.refreshToken()
        try await apiFetchAndUpdateForStart()
      }
    } catch {
      log.error(error.localizedDescription)
      
      forcedLogout()
    }
  }
  
  public func handlerOnboardingStep() async throws {
    let onboardingStep = try await solidOnboardingRepository.getOnboardingStep()
    let status = try await getMigrationStatusUseCase.execute()
    
    if status.migrationNeeded && !status.migrated {
      set(route: .accountMigration)
    } else if onboardingStep.processSteps.isEmpty {
      try await fetchUserReviewStatus()
    } else {
      let states = onboardingStep.mapToEnum()
      if states.isEmpty {
        set(route: .dashboard)
      } else {
        if states.contains(.createAccount) {
          set(route: .selecteReward)
        } else if states.contains(.accountRejected) {
          set(route: .accountReject)
        } else if states.contains(.accountInReview) {
          set(route: .kycReview)
        }
      }
    }
  }
  
  public func forcedLogout() {
    clearUserData()
    set(route: .phone)
  }
  
  public func fetchUserReviewStatus() async throws {
    let user = try await accountRepository.getUser()
    let status = try await getMigrationStatusUseCase.execute()
    
    if status.migrationNeeded && !status.migrated {
      set(route: .accountMigration)
    } else if let accountReviewStatus = user.accountReviewStatusEnum {
      switch accountReviewStatus {
      case .approved:
        set(route: .dashboard)
      case .rejected:
        set(route: .accountReject)
      case .inreview, .reviewing:
        set(route: .kycReview)
      }
    } else {
      set(route: .kycReview)
    }
    handleDataUser(user: user)
  }
}

private extension SolidOnboardingFlowCoordinator {
  func checkUserIsValid() -> Bool {
    return accountDataManager.phoneNumber.isEmpty == false
  }
  
  func apiFetchAndUpdateForStart() async throws {
    if accountDataManager.userCompleteOnboarding == false {
      try await handlerOnboardingStep()
    } else {
      try await fetchUserReviewStatus()
    }
  }
}

extension SolidOnboardingFlowCoordinator {
  private func handleDataUser(user: LFUser) {
    accountDataManager.storeUser(user: user)
    trackUserInformation(user: user)
    if let rewardType = APIRewardType(rawValue: user.userRewardType ?? "") {
      rewardDataManager.update(currentSelectReward: rewardType)
    }
    if let userSelectedFundraiserID = user.userSelectedFundraiserId {
      rewardDataManager.update(selectedFundraiserID: userSelectedFundraiserID)
    }
  }
  
  private func trackUserInformation(user: LFUser) {
    guard let userModel = user as? APIUser else { return }
    guard let data = try? JSONEncoder().encode(userModel) else { return }
    let dictionary = (try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)).flatMap { $0 as? [String: Any] }
    var values = dictionary ?? [:]
    values["birthday"] = userModel.dateOfBirth?.getDate()
    values["avatar"] = userModel.profileImage ?? ""
    values["idNumber"] = "REDACTED"
    analyticsService.set(params: values)
  }
  
  private func clearUserData() {
    log.info("<<<<<<<<<<<<<< 401 no auth and clear user data >>>>>>>>>>>>>>>")
    accountDataManager.clearUserSession()
    authorizationManager.clearToken()
    pushNotificationService.signOut()
  }
}
