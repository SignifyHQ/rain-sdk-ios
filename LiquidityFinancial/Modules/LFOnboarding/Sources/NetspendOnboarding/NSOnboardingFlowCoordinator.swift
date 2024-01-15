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
import LFRewards
import RewardData
import RewardDomain
import LFStyleGuide
import LFLocalizable
import Services
import BaseOnboarding
import ZerohashDomain
import ZerohashData

extension Container {
  public var nsOnboardingFlowCoordinator: Factory<OnboardingFlowCoordinatorProtocol> {
    self {
      NSOnboardingFlowCoordinator()
    }.singleton
  }
}

public protocol OnboardingFlowCoordinatorProtocol {
  var routeSubject: CurrentValueSubject<NSOnboardingFlowCoordinator.Route, Never> { get }
  func routeUser()
  func set(route: NSOnboardingFlowCoordinator.Route)
  func apiFetchCurrentState() async
  func handlerOnboardingStep() async throws
  func refreshNetSpendSession() async throws
  func forcedLogout()
}

public class NSOnboardingFlowCoordinator: OnboardingFlowCoordinatorProtocol {
  
  public enum Route: Hashable, Identifiable {
    
    public static func == (lhs: NSOnboardingFlowCoordinator.Route, rhs: NSOnboardingFlowCoordinator.Route) -> Bool {
      return lhs.hashValue == rhs.hashValue
    }

    case initial
    case phone
    case accountLocked
    case welcome
    case kycReview
    case dashboard
    case question(QuestionsEntity)
    case document
    case zeroHash
    case information
    case accountReject
    case unclear(String)
    case agreement
    case featureAgreement
    case popTimeUp
    case documentInReview
    case forceUpdate(FeatureConfigModel)
    case accountMigration
    
    public var id: String {
      String(describing: self)
    }
    
    public func hash(into hasher: inout Hasher) {
      switch self {
      case .question(let question):
        hasher.combine(question.id)
        hasher.combine(id)
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
    
  lazy var getQuestionUseCase: NSGetQuestionUseCaseProtocol = {
    NSGetQuestionUseCase(repository: nsPersonRepository)
  }()
  
  lazy var getDocumentsUseCase: NSGetDocumentsUseCaseProtocol = {
    NSGetDocumentsUseCase(repository: nsPersonRepository)
  }()
  
  lazy var clientSessionInitUseCase: NSClientSessionInitUseCaseProtocol = {
    NSClientSessionInitUseCase(repository: nsPersonRepository)
  }()
  
  lazy var establishingPersonUseCase: NSEstablishPersonSessionUseCaseProtocol = {
    NSEstablishPersonSessionUseCase(repository: nsPersonRepository)
  }()
  
  lazy var getOnboardingStepUseCase: NSGetOnboardingStepUseCaseProtocol = {
    NSGetOnboardingStepUseCase(repository: nsOnboardingRepository)
  }()
  
  lazy var accountUseCase: AccountUseCaseProtocol = {
    AccountUseCase(repository: accountRepository)
  }()
  
  lazy var getMigrationStatusUseCase: GetMigrationStatusUseCaseProtocol = {
    GetMigrationStatusUseCase(repository: accountRepository)
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

  public func apiFetchCurrentState() async {
    do {
      if authorizationManager.isTokenValid() {
        try await apiFetchAndUpdateForStart()
      } else {
        try await authorizationManager.refreshToken()
        try await apiFetchAndUpdateForStart()
      }
    } catch {
      log.error(error.userFriendlyMessage)
      
      if error.userFriendlyMessage.contains("identity_verification_questions_not_available") {
        set(route: .popTimeUp)
        return
      }
      
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
  
  public func handlerOnboardingStep() async throws {
    let onboardingStep = try await getOnboardingStepUseCase.execute(sessionID: accountDataManager.sessionID)
    
    if onboardingStep.processSteps.isEmpty {
      try await fetchZeroHashStatus()
    } else {
      let states = onboardingStep.mapToEnum()
      if states.isEmpty {
        set(route: .dashboard)
      } else {
        if states.contains(NSOnboardingTypeEnum.createAccount) {
          set(route: .welcome)
        } else if states.contains(NSOnboardingTypeEnum.acceptAgreement) {
          set(route: .agreement)
        } else if states.contains(NSOnboardingTypeEnum.acceptFeatureAgreement) {
          set(route: .featureAgreement)
        } else if states.contains(NSOnboardingTypeEnum.identityQuestions) {
          let questionsEncrypt = try await getQuestionUseCase.execute(sessionId: accountDataManager.sessionID)
          if let usersession = netspendDataManager.sdkSession, let questionsDecode = (questionsEncrypt as? APIQuestionData)?.decodeData(session: usersession) {
            let questionsEntity = QuestionsEntity.mapObj(questionsDecode)
            set(route: .question(questionsEntity))
          }
        } else if states.contains(NSOnboardingTypeEnum.provideDocuments) {
          let documents = try await getDocumentsUseCase.execute(sessionId: accountDataManager.sessionID)
          guard let documents = documents as? APIDocumentData else {
            log.error("Can't map document from BE")
            return
          }
          netspendDataManager.update(documentData: documents)
          if let status = documents.requestedDocuments.first?.status {
            switch status {
            case .complete:
              set(route: .kycReview)
            case .open:
              set(route: .document)
            case .reviewInProgress:
              set(route: .documentInReview)
            }
          } else {
            if documents.requestedDocuments.isEmpty {
              set(route: .kycReview)
            } else {
              set(route: .unclear("Required Document Unknown: \(documents.requestedDocuments.debugDescription)"))
            }
          }
        } else if states.contains(NSOnboardingTypeEnum.primaryPersonKYCApprove) {
          set(route: .kycReview)
        } else if states.contains(NSOnboardingTypeEnum.KYCData) {
          set(route: .unclear("Missing the information: \(NSOnboardingTypeEnum.KYCData.rawValue)"))
        } else if states.contains(NSOnboardingTypeEnum.expectedUse) {
          set(route: .unclear("Missing the information: \(NSOnboardingTypeEnum.expectedUse.rawValue)"))
        } else if states.contains(NSOnboardingTypeEnum.identityScan) {
          set(route: .unclear("Missing the information: \(NSOnboardingTypeEnum.identityScan.rawValue)"))
        }
      }
    }
  }
  
  public func forcedLogout() {
    clearUserData()
    set(route: .phone)
  }
  
  public func refreshNetSpendSession() async throws {
    log.info("<<<<<<<<<<<<<< Refresh NetSpend Session >>>>>>>>>>>>>>>")
    let token = try await clientSessionInitUseCase.execute()
    netspendDataManager.update(jwkToken: token)
    
    let sessionConnectWithJWT = await nsPersonRepository.establishingSessionWithJWKSet(jwtToken: token)
    guard let deviceData = sessionConnectWithJWT?.deviceData else { return }
    
    let establishPersonSession = try await establishingPersonUseCase.execute(deviceData: EstablishSessionParameters(encryptedData: deviceData))
    netspendDataManager.update(serverSession: establishPersonSession as? APIEstablishedSessionData)
    accountDataManager.stored(sessionID: establishPersonSession.id)
    
    let userSessionAnonymous = try nsPersonRepository.createUserSession(establishingSession: sessionConnectWithJWT, encryptedData: establishPersonSession.encryptedData)
    netspendDataManager.update(sdkSession: userSessionAnonymous)
  }
}

private extension NSOnboardingFlowCoordinator {
  func checkUserIsValid() -> Bool {
    accountDataManager.sessionID.isEmpty == false
  }
  
  func apiFetchAndUpdateForStart() async throws {
    try await refreshNetSpendSession()
    let status = try await getMigrationStatusUseCase.execute()
    if status.migrationNeeded && !status.migrated {
      set(route: .accountMigration)
    } else if accountDataManager.userCompleteOnboarding == false {
      try await handlerOnboardingStep()
    } else {
      set(route: .dashboard)
    }
  }
  
  func fetchZeroHashStatus() async throws {
    let result = try await zerohashRepository.getOnboardingStep()
    if result.missingSteps.isEmpty {
      set(route: .dashboard)
    }
    if result.mapToEnum().contains(.createAccount) {
      set(route: .zeroHash)
    } else {
      log.info("fetchZeroHashStatus: \(result.missingSteps)")
    }
  }
  
  func fetchUserReviewStatus() async throws {
    let user = try await accountRepository.getUser()
    let status = try await getMigrationStatusUseCase.execute()
    if status.migrationNeeded && !status.migrated {
      set(route: .accountMigration)
    } else if let accountReviewStatus = user.accountReviewStatusEnum {
      switch accountReviewStatus {
      case .approved:
        try await fetchZeroHashStatus()
      case .rejected:
        set(route: .accountReject)
      case .inreview, .reviewing:
        set(route: .kycReview)
      }
    } else if user.accountReviewStatus != nil {
      set(route: .unclear("Account status missing the information: \(String(describing: user.accountReviewStatus))"))
    }
    handleDataUser(user: user)
  }
}

extension NSOnboardingFlowCoordinator {
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
  
  private func handleQuestionCase() async {
    do {
      let questionsEncrypt = try await getQuestionUseCase.execute(sessionId: accountDataManager.sessionID)
      if let usersession = netspendDataManager.sdkSession, let questionsDecode = (questionsEncrypt as? APIQuestionData)?.decodeData(session: usersession) {
        let questionsEntity = QuestionsEntity.mapObj(questionsDecode)
        set(route: .question(questionsEntity))
      } else {
        set(route: .kycReview)
      }
    } catch {
      set(route: .kycReview)
      log.debug(error)
    }
  }
  
  private func clearUserData() {
    log.info("<<<<<<<<<<<<<< 401 no auth and clear user data >>>>>>>>>>>>>>>")
    accountDataManager.clearUserSession()
    authorizationManager.clearToken()
    pushNotificationService.signOut()
  }
}
