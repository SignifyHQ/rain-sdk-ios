import Foundation
import Factory
import NetSpendData
import LFUtilities
import OnboardingData
import AccountData
import OnboardingDomain
import UIKit
import LFServices
import LFStyleGuide
import AuthorizationManager

@MainActor
final class KYCStatusViewModel: ObservableObject {
  enum Navigation {
    case passport
    case address
  }
  
  @Published var state: KYCState = .idle
  @Published var presentation: Presentation?
  @Published var isLoading: Bool = false
  @Published var toastMessage: String?
  @Published var navigation: Navigation?
  
  @LazyInjected(\.netspendRepository) var netspendRepository
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.onboardingRepository) var onboardingRepository
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.onboardingFlowCoordinator) var onboardingFlowCoordinator
  @LazyInjected(\.intercomService) var intercomService
  @LazyInjected(\.authorizationManager) var authorizationManager
  
  var username: String {
    accountDataManager.userNameDisplay
  }
  private var fetchCount = 0
  private var autoRefreshTimer: Timer?
  
  init(state: KYCState) {
    _state = .init(initialValue: state)
  }
  
}

extension KYCStatusViewModel {
  
  func openIntercom() {
    intercomService.openIntercom()
  }
  
  // MARK: MAGIC PASS KYC DASHBOARD
  
  // swiftlint:disable force_unwrapping
  func magicPassKYC() {
    Task { @MainActor in
      defer { isLoading = false }
      isLoading = true
      do {
        let user = try await accountRepository.getUser()
        var request = URLRequest(url: URL(string: "https://api-crypto.dev.liquidity.cc/v1/admin/users/\(user.userID)/approve")!)
        request.httpMethod = "POST"
        let (data, response) = try await URLSession.shared.data(for: request)
        let httpResponse = response as? HTTPURLResponse
        log.debug("approved dashboard state: \(httpResponse?.statusCode ?? 000)")
        log.debug("approved dashboard data: \(data)")
        self.toastMessage = "You have been approved by the Dashboard. Please click the button Check Status and go Next Step"
      } catch {
        self.toastMessage = error.localizedDescription
        log.error(error.localizedDescription)
      }
    }
  }
  
  func primaryAction() {
    switch state {
    case .inReview:
      fetchNewStatus()
    case .reject:
      forcedLogout()
    case .missingInfo:
      forcedLogout()
    default:
      break
    }
  }
  
  func idvComplete() {
    presentation = nil
    addRefreshTimer()
  }
  
  func secondaryAction() {
    openIntercom()
  }
  
  func fetchNewStatus() {
    Task { @MainActor in
      defer { isLoading = false }
      isLoading = true
      do {
        let onboardingState = try await onboardingRepository.getOnboardingState(sessionId: accountDataManager.sessionID)
        if onboardingState.missingSteps.isEmpty {
          onboardingFlowCoordinator.set(route: .dashboard)
        } else {
          let states = onboardingState.mapToEnum()
          if states.isEmpty {
            onboardingFlowCoordinator.set(route: .dashboard)
          } else {
            if states.contains(OnboardingMissingStep.netSpendCreateAccount) {
              onboardingFlowCoordinator.set(route: .welcome)
            } else if states.contains(OnboardingMissingStep.dashboardReview) {
              onboardingFlowCoordinator.set(route: .kycReview)
            } else if states.contains(OnboardingMissingStep.zeroHashAccount) {
              onboardingFlowCoordinator.set(route: .zeroHash)
            } else if states.contains(OnboardingMissingStep.accountReject) {
              onboardingFlowCoordinator.set(route: .accountReject)
            } else if states.contains(OnboardingMissingStep.primaryPersonKYCApprove) {
              onboardingFlowCoordinator.set(route: .kycReview)
            } else if states.contains(OnboardingMissingStep.identityQuestions) {
              let questionsEncrypt = try await netspendRepository.getQuestion(sessionId: accountDataManager.sessionID)
              if let usersession = netspendDataManager.sdkSession, let questionsDecode = questionsEncrypt.decodeData(session: usersession) {
                let questionsEntity = QuestionsEntity.mapObj(questionsDecode)
                onboardingFlowCoordinator.set(route: .question(questionsEntity))
              }
            } else if states.contains(OnboardingMissingStep.provideDocuments) {
              let documents = try await netspendRepository.getDocuments(sessionId: accountDataManager.sessionID)
              netspendDataManager.update(documentData: documents)
              onboardingFlowCoordinator.set(route: .document)
            } else {
              onboardingFlowCoordinator.set(route: .unclear(states.compactMap({ $0.rawValue }).joined()))
            }
          }
        }
      } catch {
        log.error(error.localizedDescription)
        
        if error.localizedDescription.contains("identity_verification_questions_not_available") {
          onboardingFlowCoordinator.set(route: .popTimeUp)
          return
        }
        
        onboardingFlowCoordinator.forcedLogout()
      }
    }
  }
  
  func checkOnboardingState(onCompletion: @escaping () -> Void) {
    
  }
  
  func forcedLogout() {
    NotificationCenter.default.post(name: authorizationManager.logOutForcedName, object: nil)
  }
}

  // MARK: - Private Functions
private extension KYCStatusViewModel {
  func addRefreshTimer() {
      // guard !isPolling else { return }
      //    fetchCount = 0
      //    state = .loading
      //    updateUser()
      //    autoRefreshTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
      //      guard let self = self else { return }
      //      DispatchQueue.main.async {
      //        self.updateUser()
      //      }
      //    }
  }
  
  func clearRefreshTimer() {
    autoRefreshTimer?.invalidate()
  }
  
  func incrementTimer() {
    fetchCount += 1
    if fetchCount > 5 {
      clearRefreshTimer()
    }
  }
}

  // MARK: - Types
extension KYCStatusViewModel {
  enum Presentation: Identifiable {
    case idv(URL)
    
    var id: String {
      switch self {
      case .idv: return "idv"
      }
    }
  }
}
