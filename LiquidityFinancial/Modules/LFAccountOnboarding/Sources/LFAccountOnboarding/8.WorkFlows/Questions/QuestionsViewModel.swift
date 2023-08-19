import SwiftUI
import NetSpendData
import Factory
import LFUtilities
import AccountData
import OnboardingData
import AuthorizationManager

// swiftlint:disable superfluous_disable_command
@MainActor
final class QuestionsViewModel: ObservableObject {
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.authorizationManager) var authorizationManager
  @LazyInjected(\.netspendRepository) var netspendRepository
  @LazyInjected(\.onboardingRepository) var onboardingRepository
  @LazyInjected(\.onboardingFlowCoordinator) var onboardingFlowCoordinator
  @LazyInjected(\.intercomService) var intercomService

  @Published var isLoading: Bool = false
  @Published var isEnableContinue: Bool = false
  @Published var toastMessage: String?
  @Published var questionList: QuestionsEntity
  @Published var navigation: Navigation?
  @Published var popup: Popup?
  @Published var timeRemaining = Constants.kycQuestionTimeOut

  let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

  init(questionList: QuestionsEntity) {
    _questionList = .init(initialValue: questionList)
  }
}

// MARK: - View Helpers
extension QuestionsViewModel {
  func coundownTimer() {
    if timeRemaining > 0 {
      timeRemaining -= 1
    } else {
      isEnableContinue = false
      popup = .timeIsUp
      timer.upstream.connect().cancel()
    }
  }
  
  func contactSupport() {
    intercomService.openIntercom()
  }
  
  func logout() {
    apiLogout { [weak self] in
      self?.authorizationManager.clearToken()
      self?.accountDataManager.clearUserSession()
      self?.intercomService.pushEventLogout()
      self?.authorizationManager.forcedLogout()
      self?.popup = nil
    }
  }
  
  func apiLogout(onCompletion: @escaping () -> Void) {
    Task { @MainActor in
      defer { isLoading = false }
      isLoading = true
      do {
        _ = try await accountRepository.logout()
        onCompletion()
      } catch {
        onCompletion()
        log.error(error.localizedDescription)
      }
    }
  }
  
  func updateAnswerSelect(questionID: String, answerID: String) {
    let question = questionList.questions.first(where: { $0.id == questionID })
    question?.answer.forEach({ $0.isSelect = false })
    let answer = question?.answer.first(where: { $0.answerId == answerID })
    answer?.isSelect = true
    self.objectWillChange.send()
    isValidAnswerQuestion()
  }
  
  func isValidAnswerQuestion() {
    var hasAllAnswerCount = 0
    questionList.questions.forEach { answerQuestion in
      if answerQuestion.answer.contains(where: { $0.isSelect == true }) {
        hasAllAnswerCount += 1
      }
    }
    isEnableContinue = hasAllAnswerCount == 3 ? true : false
  }
  
  func actionContinue() {
    var answers: [AnswerQuestionParameters.Answers] = []
    questionList.questions.forEach { answerQuestion in
      if let answer = answerQuestion.answer.first(where: { $0.isSelect == true }) {
        answers.append(AnswerQuestionParameters.Answers(questionId: answerQuestion.id, answerId: answer.answerId))
      }
    }
    guard let session = netspendDataManager.sdkSession else { return }
    let answerQuestionParameters = AnswerQuestionParameters(answers: answers)
    let encryptedData = answerQuestionParameters.encodeObj(session: session)
    
    Task { @MainActor in
      defer { isLoading = false }
      isLoading = true
      do {
        _ = try await netspendRepository.putQuestion(sessionId: session.sessionId, encryptedData: encryptedData)
        
        try await handleWorkflows()
        
      } catch {
        log.error(error)
        toastMessage = error.localizedDescription
      }
    }
  }
}

// MARK: - Private Functions
private extension QuestionsViewModel {
  func handleWorkflows() async throws {
    let workflows = try await self.netspendRepository.getWorkflows()
    
    if workflows.steps.isEmpty {
      navigation = .kycReview
      return
    }
    
    if let steps = workflows.steps.first {
      for stepIndex in 0...(steps.steps.count - 1) {
        let step = steps.steps[stepIndex]
        switch step.missingStep {
        case .identityQuestions: //TODO: need review implement other case
          onboardingFlowCoordinator.set(route: .welcome)
        case .provideDocuments: //TODO: need review implement other case 
          let documents = try await netspendRepository.getDocuments(sessionId: accountDataManager.sessionID)
          netspendDataManager.update(documentData: documents)
          navigation = .uploadDocument
        case .KYCData:
          navigation = .missingInfo
        case .primaryPersonKYCApprove, .identityScan:
          navigation = .kycReview
        case .acceptAgreement:
          break
        case .expectedUse:
          break
        case .acceptFeatureAgreement:
          break
        }
      }
    }
  }
}

// MARK: - Types
extension QuestionsViewModel {
  enum Navigation {
    case kycReview
    case uploadDocument
    case missingInfo
  }
  
  enum Popup {
    case timeIsUp
  }
}
