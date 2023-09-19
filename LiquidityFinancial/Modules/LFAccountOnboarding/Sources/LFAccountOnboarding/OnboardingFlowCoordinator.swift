import SwiftUI
import LFUtilities
import Combine
import Factory
import NetSpendData
import OnboardingData
import AccountData
import AccountDomain
import OnboardingDomain
import LFRewards
import RewardData
import RewardDomain
import LFStyleGuide
import LFLocalizable

public protocol OnboardingFlowCoordinatorProtocol {
  var routeSubject: CurrentValueSubject<OnboardingFlowCoordinator.Route, Never> { get }
  func routeUser()
  func set(route: OnboardingFlowCoordinator.Route)
  func apiFetchCurrentState() async
  func forcedLogout()
}

public class OnboardingFlowCoordinator: OnboardingFlowCoordinatorProtocol {
  
  public enum Route: Hashable, Identifiable {
    
    public static func == (lhs: OnboardingFlowCoordinator.Route, rhs: OnboardingFlowCoordinator.Route) -> Bool {
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
  @LazyInjected(\.nsPersionRepository) var nsPersionRepository
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  @LazyInjected(\.rewardFlowCoordinator) var rewardFlowCoordinator
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.rewardDataManager) var rewardDataManager
  @LazyInjected(\.pushNotificationService) var pushNotificationService
  
  public let routeSubject: CurrentValueSubject<Route, Never>
  
  private var subscribers: Set<AnyCancellable> = []
  
  public init() {
    self.routeSubject = .init(.initial)
    rewardFlowCoordinator
      .routeSubject
      .removeDuplicates()
      .receive(on: DispatchQueue.main)
      .sink { [weak self] route in
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

  func handlerRewardRoute(route: RewardFlowCoordinator.Route) {
    switch route {
    case .information:
      set(route: .information)
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
      
      if error.localizedDescription.contains("identity_verification_questions_not_available") {
        set(route: .popTimeUp)
        return
      }
      
      forcedLogout()
    }
  }
  
  func checkUserIsValid() -> Bool {
    accountDataManager.sessionID.isEmpty == false
  }
  
  // swiftlint:disable function_body_length
  func apiFetchAndUpdateForStart() async throws {
    try await refreshNetSpendSession()
    
    async let fetchUser = accountRepository.getUser()
    let user = try await fetchUser
    handleDataUser(user: user)
    
    if accountDataManager.userCompleteOnboarding == false {
      async let fetchOnboardingState = onboardingRepository.getOnboardingState(sessionId: accountDataManager.sessionID)
      
      let onboardingState = try await fetchOnboardingState
      
      if onboardingState.missingSteps.isEmpty {
        set(route: .dashboard)
      } else {
        let states = onboardingState.mapToEnum()
        if states.isEmpty {
          set(route: .dashboard)
        } else {
          if states.contains(OnboardingMissingStep.netSpendCreateAccount) {
            set(route: .welcome)
          } else if states.contains(OnboardingMissingStep.acceptAgreement) {
            set(route: .agreement)
          } else if states.contains(OnboardingMissingStep.acceptFeatureAgreement) {
            set(route: .featureAgreement)
          } else if states.contains(OnboardingMissingStep.identityQuestions) {
            let questionsEncrypt = try await nsPersionRepository.getQuestion(sessionId: accountDataManager.sessionID)
            if let usersession = netspendDataManager.sdkSession, let questionsDecode = (questionsEncrypt as? APIQuestionData)?.decodeData(session: usersession) {
              let questionsEntity = QuestionsEntity.mapObj(questionsDecode)
              set(route: .question(questionsEntity))
            }
          } else if states.contains(OnboardingMissingStep.provideDocuments) {
            let documents = try await nsPersionRepository.getDocuments(sessionId: accountDataManager.sessionID)
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
          } else if states.contains(OnboardingMissingStep.dashboardReview) {
            set(route: .kycReview)
          } else if states.contains(OnboardingMissingStep.zeroHashAccount) {
            set(route: .zeroHash)
          } else if states.contains(OnboardingMissingStep.accountReject) {
            set(route: .accountReject)
          } else if states.contains(OnboardingMissingStep.primaryPersonKYCApprove) {
            set(route: .kycReview)
          } else {
            set(route: .unclear(states.compactMap({ $0.rawValue }).joined()))
          }
        }
      }
    } else {
      set(route: .dashboard)
    }
  }
  // swiftlint:enable function_body_length

  public func forcedLogout() {
    clearUserData()
    set(route: .phone)
  }
}

extension OnboardingFlowCoordinator {
  private func handleDataUser(user: LFUser) {
    accountDataManager.storeUser(user: user)
    if let rewardType = APIRewardType(rawValue: user.userRewardType ?? "") {
      rewardDataManager.update(currentSelectReward: rewardType)
    }
    if let userSelectedFundraiserID = user.userSelectedFundraiserId {
      rewardDataManager.update(selectedFundraiserID: userSelectedFundraiserID)
    }
  }
  
  private func handleQuestionCase() async {
    do {
      let questionsEncrypt = try await nsPersionRepository.getQuestion(sessionId: accountDataManager.sessionID)
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
  
  private func refreshNetSpendSession() async throws {
    log.info("<<<<<<<<<<<<<< Refresh NetSpend Session >>>>>>>>>>>>>>>")
    let token = try await nsPersionRepository.clientSessionInit()
    netspendDataManager.update(jwkToken: token)
    
    let sessionConnectWithJWT = await nsPersionRepository.establishingSessionWithJWKSet(jwtToken: token)
    guard let deviceData = sessionConnectWithJWT?.deviceData else { return }
    
    let establishPersonSession = try await nsPersionRepository.establishPersonSession(deviceData: EstablishSessionParameters(encryptedData: deviceData))
    netspendDataManager.update(serverSession: establishPersonSession as? APIEstablishedSessionData)
    accountDataManager.stored(sessionID: establishPersonSession.id)
    
    let userSessionAnonymous = try nsPersionRepository.createUserSession(establishingSession: sessionConnectWithJWT, encryptedData: establishPersonSession.encryptedData)
    netspendDataManager.update(sdkSession: userSessionAnonymous)
  }
}
