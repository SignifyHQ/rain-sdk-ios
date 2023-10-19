import SwiftUI
import NetSpendData
import Factory
import LFUtilities
import AccountData
import OnboardingData
import AuthorizationManager

// swiftlint:disable superfluous_disable_command
@MainActor
public final class QuestionsViewModel: ObservableObject {
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.authorizationManager) var authorizationManager
  @LazyInjected(\.nsPersionRepository) var nsPersionRepository
  @LazyInjected(\.onboardingRepository) var onboardingRepository
  @LazyInjected(\.nsOnboardingRepository) var nsOnboardingRepository
  @LazyInjected(\.nsOnboardingFlowCoordinator) var onboardingFlowCoordinator
  @LazyInjected(\.customerSupportService) var customerSupportService
  @LazyInjected(\.pushNotificationService) var pushNotificationService

  @Published var isLoading: Bool = false
  @Published var isEnableContinue: Bool = false
  @Published var toastMessage: String?
  @Published var questionList: QuestionsEntity
  @Published var navigation: Navigation?
  @Published var popup: Popup?
  @Published var timeRemaining = Constants.kycQuestionTimeOut
  
  let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

  public init(questionList: QuestionsEntity = .mockKYCQuestion) {
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
    customerSupportService.openSupportScreen()
  }
  
  func logout() {
    apiLogout { [weak self] in
      self?.authorizationManager.clearToken()
      self?.accountDataManager.clearUserSession()
      self?.customerSupportService.pushEventLogout()
      self?.authorizationManager.forcedLogout()
      self?.popup = nil
      self?.pushNotificationService.signOut()
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
        _ = try await nsPersionRepository.putQuestion(sessionId: session.sessionId, encryptedData: encryptedData)
        
        try await handlerOnboardingStep()
        
      } catch {
        if error.localizedDescription.contains("identity_verification_questions_not_available") {
          onboardingFlowCoordinator.set(route: .popTimeUp)
          return
        }
        
        log.error(error)
        toastMessage = error.localizedDescription
      }
    }
  }
}

// MARK: - Private Functions
private extension QuestionsViewModel {  
  func handlerOnboardingStep() async throws {
    let onboardingStep = try await nsOnboardingRepository.getOnboardingStep(sessionID: accountDataManager.sessionID)
    let onboardingTypes = onboardingStep.mapToEnum()
    if onboardingTypes.isEmpty {
      navigation = .kycReview
      return
    }
    
    if onboardingTypes.contains(.identityQuestions) {
      onboardingFlowCoordinator.set(route: .unclear("You can't upload question for now, Please try it late."))
    } else if onboardingTypes.contains(.provideDocuments) {
      let documents = try await nsPersionRepository.getDocuments(sessionId: accountDataManager.sessionID)
      guard let documents = documents as? APIDocumentData else {
        log.error("Can't map document from BE")
        return
      }
      netspendDataManager.update(documentData: documents)
      navigation = .uploadDocument
    } else if onboardingTypes.contains(.KYCData) {
      navigation = .missingInfo
    } else if onboardingTypes.contains(.primaryPersonKYCApprove) {
      navigation = .kycReview
    } else if onboardingTypes.contains(.acceptAgreement) {
      navigation = .agreement
    } else if onboardingTypes.contains(.expectedUse) {
      navigation = .missingInfo
    } else if onboardingTypes.contains(.identityScan) {
      navigation = .missingInfo
    } else if onboardingTypes.contains(.acceptFeatureAgreement) {
      navigation = .agreement
    }
  }
}

// MARK: - Types
extension QuestionsViewModel {
  enum Navigation {
    case kycReview
    case uploadDocument
    case missingInfo
    case agreement
  }
  
  enum Popup {
    case timeIsUp
  }
}
