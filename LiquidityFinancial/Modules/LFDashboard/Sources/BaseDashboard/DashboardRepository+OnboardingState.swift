import Foundation
import NetspendOnboarding
import OnboardingData
import OnboardingDomain
import LFUtilities
import NetSpendData

public extension DashboardRepository {
  
  // swiftlint:disable function_body_length
  func apiFetchOnboardingState(onChangeRoute: @escaping ((NSOnboardingFlowCoordinator.Route) -> Void)) {
    Task { @MainActor in
      do {
        async let fetchOnboardingState = onboardingRepository.onboardingState(sessionId: accountDataManager.sessionID)
        
        let onboardingState = try await fetchOnboardingState
        
        if onboardingState.missingSteps.isEmpty {
          log.info("Current OnboardingState in Dashboard is Empty")
        } else {
          let states = onboardingState.mapToEnum()
          if states.isEmpty {
            log.info("Current OnboardingState in Dashboard is Empty")
          } else {
            if states.contains(OnboardingMissingStep.netSpendCreateAccount) {
              return
            } else if states.contains(OnboardingMissingStep.acceptAgreement) {
              onChangeRoute(.agreement)
            } else if states.contains(OnboardingMissingStep.acceptFeatureAgreement) {
              onChangeRoute(.featureAgreement)
            } else if states.contains(OnboardingMissingStep.identityQuestions) {
              let questionsEncrypt = try await nsPersionRepository.getQuestion(sessionId: accountDataManager.sessionID)
              if let usersession = netspendDataManager.sdkSession, let questionsDecode = (questionsEncrypt as? APIQuestionData)?.decodeData(session: usersession) {
                let questionsEntity = QuestionsEntity.mapObj(questionsDecode)
                onChangeRoute(.question(questionsEntity))
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
                  onChangeRoute(.kycReview)
                case .open:
                  onChangeRoute(.document)
                case .reviewInProgress:
                  onChangeRoute(.documentInReview)
                }
              } else {
                if documents.requestedDocuments.isEmpty {
                  onChangeRoute(.kycReview)
                } else {
                  onChangeRoute(.unclear("Required Document Unknown: \(documents.requestedDocuments.debugDescription)"))
                }
              }
            } else if states.contains(OnboardingMissingStep.dashboardReview) {
              onChangeRoute(.kycReview)
            } else if states.contains(OnboardingMissingStep.zeroHashAccount) {
              onChangeRoute(.zeroHash)
            } else if states.contains(OnboardingMissingStep.accountReject) {
              onChangeRoute(.accountReject)
            } else if states.contains(OnboardingMissingStep.primaryPersonKYCApprove) {
              onChangeRoute(.kycReview)
            } else {
              onChangeRoute(.unclear(states.compactMap({ $0.rawValue }).joined()))
            }
          }
        }
      } catch {
        log.error(error.localizedDescription)
      }
    }
  }
  // swiftlint:enable function_body_length
  
}
