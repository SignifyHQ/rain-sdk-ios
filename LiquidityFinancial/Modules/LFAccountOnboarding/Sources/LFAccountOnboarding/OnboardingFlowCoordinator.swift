import SwiftUI
import LFUtilities
import Combine
import Factory
import NetSpendData
import OnboardingData
import OnboardingDomain

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
  @LazyInjected(\.userDataManager) var userDataManager
  @LazyInjected(\.onboardingRepository) var onboardingRepository
  @LazyInjected(\.netspendRepository) var netspendRepository
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  
  public let routeSubject: CurrentValueSubject<Route, Never>
  
  public init() {
    self.routeSubject = .init(.initial)
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

  func getCurrentState() {
    Task { @MainActor in
      do {
        let onboardingState = try await onboardingRepository.getOnboardingState(sessionId: userDataManager.sessionID)
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
        if let error = error.asErrorObject, let code = error.code, code == "user_not_authorized" {
          clearUserData()
        }
        routeSubject.value = .phone
        log.error(error.localizedDescription)
      }
    }
  }
  
  private func handleQuestionCase() async {
    do {
      let questionsEncrypt = try await netspendRepository.getQuestion(sessionId: userDataManager.sessionID)
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
      let documents = try await netspendRepository.getDocuments(sessionId: userDataManager.sessionID)
      netspendDataManager.update(documentData: documents)
      routeSubject.value = .document
    } catch {
      routeSubject.value = .kycReview
      log.debug(error)
    }
  }
  
  private func clearUserData() {
    userDataManager.clearUserSession()
    authorizationManager.clearToken()
  }
}
