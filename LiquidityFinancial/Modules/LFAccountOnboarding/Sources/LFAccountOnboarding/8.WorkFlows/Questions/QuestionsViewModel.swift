import SwiftUI
import NetSpendData
import Factory
import LFUtilities
import OnboardingDomain
import OnboardingData

@MainActor
final class QuestionsViewModel: ObservableObject {
  enum Navigation {
    case kycReview
    case uploadDocument
  }
  
  @Injected(\.netspendDataManager) var netspendDataManager
  @Injected(\.userDataManager) var userDataManager
  @Injected(\.netspendRepository) var netspendRepository
  @Injected(\.onboardingRepository) var onboardingRepository
  
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
        if let onboardingState = try await onboardingRepository.getOnboardingState(sessionId: userDataManager.sessionID) as? APIOnboardingState {
          let listEnumState = onboardingState.mapToEnum()
          if listEnumState.isEmpty {
              //Go Home Screen
          } else {
            if listEnumState.contains(where: { $0 == .primaryPersonKYCApprove }) {
              navigation = .kycReview
            } else if listEnumState.contains(where: { $0 == .provideDocuments }) {
              navigation = .uploadDocument
            }
          }
        }
      } catch {
        log.error(error)
        toastMessage = error.localizedDescription
      }
    }
  }
  
}
