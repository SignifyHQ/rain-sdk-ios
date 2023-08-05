import SwiftUI
import NetSpendData
import Factory
import LFUtilities
import AccountData
import OnboardingData

// swiftlint:disable superfluous_disable_command
@MainActor
final class QuestionsViewModel: ObservableObject {
  enum Navigation {
    case kycReview
    case uploadDocument
    case missingInfo
  }
  
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.netspendRepository) var netspendRepository
  @LazyInjected(\.onboardingRepository) var onboardingRepository
  @LazyInjected(\.onboardingFlowCoordinator) var onboardingFlowCoordinator
  
  @Published var isLoading: Bool = false
  @Published var isEnableContinue: Bool = false
  @Published var toastMessage: String?
  @Published var questionList: QuestionsEntity
  @Published var navigation: Navigation?
  
  init(questionList: QuestionsEntity) {
    _questionList = .init(initialValue: questionList)
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
  
  private func handleWorkflows() async throws {
    let workflows = try await self.netspendRepository.getWorkflows()
    
    if workflows.steps.isEmpty {
      navigation = .kycReview
      return
    }
    
    if let steps = workflows.steps.first {
      for stepIndex in 0...(steps.steps.count - 1) {
        let step = steps.steps[stepIndex]
        switch step.missingStep {
        case .identityQuestions:
          onboardingFlowCoordinator.set(route: .welcome)
        case .provideDocuments:
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
        }
      }
    }
  }
}
