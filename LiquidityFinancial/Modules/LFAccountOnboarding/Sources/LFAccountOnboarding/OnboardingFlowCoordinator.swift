import SwiftUI
import LFUtilities
import Combine
import Factory
import NetSpendData
import OnboardingData
import AccountData
import OnboardingDomain
import LFRewards

// swiftlint:disable cyclomatic_complexity
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
    guard routeSubject.value != route else { return }
    log.info("OnboardingFlowCoordinator route: \(route), with current route: \(routeSubject.value)")
    routeSubject.send(route)
  }
  
  public func routeUser() {
    if authorizationManager.isTokenValid() {
      getCurrentState()
    } else {
      clearUserData()
      routeSubject.value = .phone
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
  
  func getCurrentState() {
    Task { @MainActor in
      do {
        
        let onboardingState = try await onboardingRepository.getOnboardingState(sessionId: accountDataManager.sessionID)
        try await refreshNetSpendSession()
        
        if onboardingState.missingSteps.isEmpty {
          
          routeSubject.value = .dashboard
          
        } else {
          
          let states = onboardingState.mapToEnum()
          if states.isEmpty {
            if onboardingState.missingSteps.count == 1 {
              if onboardingState.missingSteps.contains(WorkflowsMissingStep.provideDocuments.rawValue) {
                await handleUpDocumentCase()
              } else if onboardingState.missingSteps.contains(WorkflowsMissingStep.identityQuestions.rawValue) {
                await handleQuestionCase()
              } else {
                //TODO: Tony need review after
                routeSubject.value = .kycReview
              }
            } else {
              //TODO: Tony need review after
              routeSubject.value = .kycReview
            }
          } else {
            if states.contains(OnboardingMissingStep.netSpendCreateAccount) {
              routeSubject.value = .welcome
            } else if states.contains(OnboardingMissingStep.dashboardReview) {
              routeSubject.value = .kycReview
            } else if states.contains(OnboardingMissingStep.zeroHashAccount) {
              routeSubject.value = .zeroHash
            } else if states.contains(OnboardingMissingStep.cardProvision) {
              //TODO: Tony need review after
            }
          }
          
        }
      } catch {
        if error.localizedDescription.contains("user_not_authorized") {
          clearUserData()
        }
        if error.localizedDescription.contains("user_not_found") {
          clearUserData()
          //TODO: tony review implelement late
        }
        routeSubject.value = .phone
        log.error(error.localizedDescription)
      }
    }
  }
  
  private func handleQuestionCase() async {
    do {
      let questionsEncrypt = try await netspendRepository.getQuestion(sessionId: accountDataManager.sessionID)
      if let usersession = netspendDataManager.sdkSession, let questionsDecode = questionsEncrypt.decodeData(session: usersession) {
        let questionsEntity = QuestionsEntity.mapObj(questionsDecode)
        routeSubject.value = .question(questionsEntity)
      } else {
        routeSubject.value = .kycReview
      }
    } catch {
      routeSubject.value = .kycReview
      log.debug(error)
    }
  }
  
  private func handleUpDocumentCase() async {
    do {
      let documents = try await netspendRepository.getDocuments(sessionId: accountDataManager.sessionID)
      netspendDataManager.update(documentData: documents)
      routeSubject.value = .document
    } catch {
      routeSubject.value = .kycReview
      log.debug(error)
    }
  }
  
  private func clearUserData() {
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
