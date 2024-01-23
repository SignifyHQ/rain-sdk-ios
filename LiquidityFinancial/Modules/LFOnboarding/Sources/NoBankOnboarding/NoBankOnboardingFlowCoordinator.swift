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
import UIComponents
import ZerohashDomain
import ZerohashData

extension Container {
  public var noBankOnboardingFlowCoordinator: Factory<OnboardingFlowCoordinatorProtocol> {
    self {
      NoBankOnboardingFlowCoordinator()
    }.singleton
  }
}

public protocol OnboardingFlowCoordinatorProtocol {
  var routeSubject: CurrentValueSubject<NoBankOnboardingFlowCoordinator.Route, Never> { get }
  func routeUser()
  func set(route: NoBankOnboardingFlowCoordinator.Route)
  func apiFetchCurrentState() async
  func forcedLogout()
}

public class NoBankOnboardingFlowCoordinator: OnboardingFlowCoordinatorProtocol {
  
  public enum Route: Hashable, Identifiable {
    
    public static func == (lhs: NoBankOnboardingFlowCoordinator.Route, rhs: NoBankOnboardingFlowCoordinator.Route) -> Bool {
      return lhs.hashValue == rhs.hashValue
    }

    case initial
    case phone
    case accountLocked
    case dashboard
    case forceUpdate(FeatureConfigModel)
    case noBankPopup
    
    public var id: String {
      String(describing: self)
    }
    
    public func hash(into hasher: inout Hasher) {
      switch self {
      default:
        hasher.combine(id)
      }
    }
  }
  
  @LazyInjected(\.authorizationManager) var authorizationManager
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.onboardingRepository) var onboardingRepository
  @LazyInjected(\.nsPersonRepository) var nsPersonRepository
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.pushNotificationService) var pushNotificationService
  @LazyInjected(\.analyticsService) var analyticsService
  @LazyInjected(\.nsOnboardingRepository) var nsOnboardingRepository
  @LazyInjected(\.zerohashRepository) var zerohashRepository
  
  lazy var accountUseCase: AccountUseCaseProtocol = {
    AccountUseCase(repository: accountRepository)
  }()
  
  public let routeSubject: CurrentValueSubject<Route, Never>
  
  public var accountFeatureConfigData = AccountFeatureConfigData(configJSON: "", isLoading: false)
  
  public init() {
    self.routeSubject = .init(.initial)
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
      await apiFetchCurrentState()
#if DEBUG
      let diff = CFAbsoluteTimeGetCurrent() - start
      log.debug("Took \(diff) seconds")
#endif
    }
  }

  public func apiFetchCurrentState() async {
    do {
      if authorizationManager.isTokenValid() {
        try await fetchUserReviewStatus()
      } else {
        try await authorizationManager.refreshToken()
        try await fetchUserReviewStatus()
      }
    } catch {
      log.error(error.userFriendlyMessage)
      forcedLogout()
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
      accountDataManager.featureConfig = accountFeatureConfigData.featureConfig
    } catch {
      log.error(error.userFriendlyMessage)
    }
  }
  
  public func forcedLogout() {
    clearUserData()
    set(route: .phone)
  }
}

private extension NoBankOnboardingFlowCoordinator {
  func fetchZeroHashStatus() async throws {
    let result = try await zerohashRepository.getOnboardingStep()
    if result.missingSteps.isEmpty {
      set(route: .dashboard)
      return
    }
    set(route: .noBankPopup)
  }
  
  func fetchUserReviewStatus() async throws {
    let user = try await accountRepository.getUser()
    if let accountReviewStatus = user.accountReviewStatusEnum {
      switch accountReviewStatus {
      case .approved:
        set(route: .dashboard)
      case .rejected:
        set(route: .noBankPopup)
      case .inreview, .reviewing:
        set(route: .noBankPopup)
      }
    } else if user.accountReviewStatus != nil {
      set(route: .noBankPopup)
    }
    handleDataUser(user: user)
  }
}

extension NoBankOnboardingFlowCoordinator {
  private func handleDataUser(user: LFUser) {
    accountDataManager.storeUser(user: user)
    trackUserInformation(user: user)
  }
  
  private func trackUserInformation(user: LFUser) {
    guard let userModel = user as? APIUser else { return }
    guard let data = try? JSONEncoder().encode(userModel) else { return }
    let dictionary = (try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)).flatMap { $0 as? [String: Any] }
    var values = dictionary ?? [:]
    values["birthday"] = LiquidityDateFormatter.simpleDate.parseToDate(from: userModel.dateOfBirth ?? "")
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
