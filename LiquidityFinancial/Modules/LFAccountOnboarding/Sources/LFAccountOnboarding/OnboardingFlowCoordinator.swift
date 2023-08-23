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

public protocol OnboardingFlowCoordinatorProtocol {
  var routeSubject: CurrentValueSubject<OnboardingFlowCoordinator.Route, Never> { get }
  func routeUser()
  func set(route: OnboardingFlowCoordinator.Route)
}

public class OnboardingFlowCoordinator: OnboardingFlowCoordinatorProtocol {
  
  public enum Route: Hashable, Identifiable {
    
    public static func == (lhs: OnboardingFlowCoordinator.Route, rhs: OnboardingFlowCoordinator.Route) -> Bool {
      return lhs.hashValue == rhs.hashValue
    }

    case initial
    case phone
    case welcome
    case kycReview
    case dashboard
    case question(QuestionsEntity)
    case document
    case zeroHash
    case information
    case accountReject
    case unclear(String)
    
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
  @LazyInjected(\.netspendRepository) var netspendRepository
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  @LazyInjected(\.rewardFlowCoordinator) var rewardFlowCoordinator
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.rewardDataManager) var rewardDataManager
  
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
    apiFetchCurrentState()
  }

  func handlerRewardRoute(route: RewardFlowCoordinator.Route) {
    switch route {
    case .information:
      set(route: .information)
    case .selectReward:
      break //do not thing
    }
  }
  
  func apiFetchCurrentState() {
    Task { @MainActor in
      do {
        let user = try await accountRepository.getUser()
        handleDataUser(user: user)
        
        try await refreshNetSpendSession()
        
        let onboardingState = try await onboardingRepository.getOnboardingState(sessionId: accountDataManager.sessionID)
        
        if onboardingState.missingSteps.isEmpty {
          set(route: .dashboard)
        } else {
          let states = onboardingState.mapToEnum()
          if states.isEmpty {
            set(route: .dashboard)
          } else {
            if states.contains(OnboardingMissingStep.netSpendCreateAccount) {
              set(route: .welcome)
            } else if states.contains(OnboardingMissingStep.dashboardReview) {
              set(route: .kycReview)
            } else if states.contains(OnboardingMissingStep.zeroHashAccount) {
              set(route: .zeroHash)
            } else if states.contains(OnboardingMissingStep.accountReject) {
              set(route: .accountReject)
            } else if states.contains(OnboardingMissingStep.primaryPersonKYCApprove) {
              set(route: .kycReview)
            } else if states.contains(OnboardingMissingStep.identityQuestions) {
              let questionsEncrypt = try await netspendRepository.getQuestion(sessionId: accountDataManager.sessionID)
              if let usersession = netspendDataManager.sdkSession, let questionsDecode = questionsEncrypt.decodeData(session: usersession) {
                let questionsEntity = QuestionsEntity.mapObj(questionsDecode)
                set(route: .question(questionsEntity))
              }
            } else if states.contains(OnboardingMissingStep.provideDocuments) {
              let documents = try await netspendRepository.getDocuments(sessionId: accountDataManager.sessionID)
              netspendDataManager.update(documentData: documents)
              set(route: .document)
            } else {
              set(route: .unclear(states.compactMap({ $0.rawValue }).joined()))
            }
          }
        }
      } catch {
        if error.localizedDescription.contains("user_not_authorized") {
          clearUserData()
        }
        if error.localizedDescription.contains("user_not_found") {
          clearUserData()
        }
        set(route: .phone)
        log.error(error.localizedDescription)
      }
    }
  }
}

extension OnboardingFlowCoordinator {
  private func handleDataUser(user: LFUser) {
    accountDataManager.storeUser(user: user)
    if let rewardType = APIRewardType(rawValue: user.userRewardType ?? "") {
      rewardDataManager.update(currentSelectReward: rewardType)
    }
  }
  
  private func handleQuestionCase() async {
    do {
      let questionsEncrypt = try await netspendRepository.getQuestion(sessionId: accountDataManager.sessionID)
      if let usersession = netspendDataManager.sdkSession, let questionsDecode = questionsEncrypt.decodeData(session: usersession) {
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
  
  private func handleUpDocumentCase() async {
    do {
      let documents = try await netspendRepository.getDocuments(sessionId: accountDataManager.sessionID)
      netspendDataManager.update(documentData: documents)
      set(route: .document)
    } catch {
      set(route: .kycReview)
      log.debug(error)
    }
  }
  
  private func clearUserData() {
    log.info("<<<<<<<<<<<<<< 401 no auth and clear user data >>>>>>>>>>>>>>>")
    accountDataManager.clearUserSession()
    authorizationManager.clearToken()
  }
  
  private func refreshNetSpendSession() async throws {
    log.info("<<<<<<<<<<<<<< Refresh NetSpend Session >>>>>>>>>>>>>>>")
    let token = try await netspendRepository.clientSessionInit()
    netspendDataManager.update(jwkToken: token)
    
    let sessionConnectWithJWT = await netspendRepository.establishingSessionWithJWKSet(jwtToken: token)
    
    guard let deviceData = sessionConnectWithJWT?.deviceData else { return }
    
    let establishPersonSession = try await netspendRepository.establishPersonSession(deviceData: EstablishSessionParameters(encryptedData: deviceData))
    netspendDataManager.update(serverSession: establishPersonSession)
    accountDataManager.stored(sessionID: establishPersonSession.id)
    
    let userSessionAnonymous = try netspendRepository.createUserSession(establishingSession: sessionConnectWithJWT, encryptedData: establishPersonSession.encryptedData)
    netspendDataManager.update(sdkSession: userSessionAnonymous)
  }
}
