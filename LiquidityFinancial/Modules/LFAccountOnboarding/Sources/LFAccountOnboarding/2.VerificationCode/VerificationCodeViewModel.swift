import Foundation
import LFUtilities
import OnboardingDomain
import Combine
import SwiftUI
import NetSpendData
import Factory
import NetspendSdk
import LFServices
import AccountData
import AccountDomain
import RewardData
import RewardDomain

@MainActor
final class VerificationCodeViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.onboardingRepository) var onboardingRepository
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.onboardingFlowCoordinator) var onboardingFlowCoordinator
  @LazyInjected(\.netspendRepository) var netspendRepository
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  @LazyInjected(\.rewardDataManager) var rewardDataManager
  @LazyInjected(\.intercomService) var intercomService
  
  @Published var isNavigationToWelcome: Bool = false
  @Published var isResendButonTimerOn = false
  @Published var isShowText: Bool = true
  @Published var isShowLoading: Bool = false
  @Published var formatPhoneNumber: String = ""
  @Published var otpCode: String = ""
  @Published var timeString: String = ""
  @Published var toastMessage: String?
  @Published var errorMessage: String?
  
  var cancellables: Set<AnyCancellable> = []
  lazy var requestOtpUseCase: RequestOTPUseCaseProtocol = {
    RequestOTPUseCase(repository: onboardingRepository)
  }()
  lazy var loginUseCase: LoginUseCaseProtocol = {
    LoginUseCase(repository: onboardingRepository)
  }()
  
  init(phoneNumber: String) {
    formatPhoneNumber = Constants.Default.regionCode.rawValue + phoneNumber
  }
}

  // MARK: API
extension VerificationCodeViewModel {
  func performVerifyOTPCode(formatPhoneNumber: String, code: String) {
    guard !isShowLoading else { return }
    isShowLoading = true
    Task {
#if DEBUG
      let start = CFAbsoluteTimeGetCurrent()
#endif
      do {
        _ = try await loginUseCase.execute(phoneNumber: formatPhoneNumber, code: code)
        accountDataManager.update(phone: formatPhoneNumber)
        accountDataManager.stored(phone: formatPhoneNumber)
        
        if LFUtility.charityEnabled { // we enalbe showRoundUpForCause after user login
          UserDefaults.showRoundUpForCause = true
        }
        
        intercomService.loginIdentifiedUser(userAttributes: IntercomService.UserAttributes(phone: formatPhoneNumber))
        
        try await initNetSpendSession()
        await checkOnboardingState()
        
        self.isShowLoading = false
        
      } catch {
        self.isShowLoading = false
        if error.localizedDescription.contains("credentials_invalid") {
          toastMessage = "OTP is invalid. Please resend OTP"
        } else {
          toastMessage = error.localizedDescription
        }
        
        log.error(error)
      }
#if DEBUG
      let diff = CFAbsoluteTimeGetCurrent() - start
      log.debug("Took \(diff) seconds")
#endif
    }
  }
  
  func performGetOTP(formatPhoneNumber: String) {
    Task {
      do {
        _ = try await requestOtpUseCase.execute(phoneNumber: formatPhoneNumber)
        isShowLoading = false
      } catch {
        isShowLoading = false
        toastMessage = error.localizedDescription
      }
    }
  }
  
  func performAutoGetTwilioMessagesIfNeccessary() {
    DemoAccountsHelper.shared.getTwilioMessages(for: formatPhoneNumber)
      .removeDuplicates()
      .receive(on: DispatchQueue.main)
      .sink { [weak self] code in
        guard let self else { return }
        log.debug(code ?? "performGetTwilioMessagesIfNeccessary not found")
        guard let code = code else { return }
        self.otpCode = code
        self.performVerifyOTPCode(formatPhoneNumber: formatPhoneNumber, code: code)
      }
      .store(in: &cancellables)
  }
  
  func openIntercom() {
    intercomService.openIntercom()
  }
}

  // MARK: View Helpers
extension VerificationCodeViewModel {
  func onChangedOTPCode() {
    if otpCode.count == Constants.MaxCharacterLimit.verificationLimit.value {
      performVerifyOTPCode(formatPhoneNumber: formatPhoneNumber, code: otpCode)
    }
  }
  
  func resendOTP() {
    performGetOTP(formatPhoneNumber: formatPhoneNumber)
  }
}

  // MARK: Private
extension VerificationCodeViewModel {
  private func initNetSpendSession() async throws {
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
  
  private func checkUserIsValid() -> Bool {
    accountDataManager.sessionID.isEmpty == false
  }
  
  private func handleDataUser(user: LFUser) {
    accountDataManager.storeUser(user: user)
    if let rewardType = APIRewardType(rawValue: user.userRewardType ?? "") {
      rewardDataManager.update(currentSelectReward: rewardType)
    }
    if let userSelectedFundraiserID = user.userSelectedFundraiserId {
      rewardDataManager.update(selectedFundraiserID: userSelectedFundraiserID)
    }
  }
  
  // swiftlint:disable function_body_length
  @MainActor
  private func checkOnboardingState() async {
    do {
      async let fetchUser = accountRepository.getUser()
      let user = try await fetchUser
      handleDataUser(user: user)
      
      if accountDataManager.userCompleteOnboarding == false {
        async let fetchOnboardingState = onboardingRepository.getOnboardingState(sessionId: accountDataManager.sessionID)
        
        let onboardingState = try await fetchOnboardingState
        
        if onboardingState.missingSteps.isEmpty {
          self.onboardingFlowCoordinator.set(route: .dashboard)
        } else {
          let states = onboardingState.mapToEnum()
          if states.isEmpty {
            self.onboardingFlowCoordinator.set(route: .dashboard)
          } else {
            if states.contains(OnboardingMissingStep.netSpendCreateAccount) {
              onboardingFlowCoordinator.set(route: .welcome)
            } else if states.contains(OnboardingMissingStep.acceptAgreement) {
              onboardingFlowCoordinator.set(route: .agreement)
            } else if states.contains(OnboardingMissingStep.acceptFeatureAgreement) {
              onboardingFlowCoordinator.set(route: .featureAgreement)
            } else if states.contains(OnboardingMissingStep.identityQuestions) {
              let questionsEncrypt = try await netspendRepository.getQuestion(sessionId: accountDataManager.sessionID)
              if let usersession = netspendDataManager.sdkSession, let questionsDecode = questionsEncrypt.decodeData(session: usersession) {
                let questionsEntity = QuestionsEntity.mapObj(questionsDecode)
                onboardingFlowCoordinator.set(route: .question(questionsEntity))
              }
            } else if states.contains(OnboardingMissingStep.provideDocuments) {
              let documents = try await netspendRepository.getDocuments(sessionId: accountDataManager.sessionID)
              netspendDataManager.update(documentData: documents)
              if let status = documents.requestedDocuments.first?.status {
                switch status {
                case .complete:
                  onboardingFlowCoordinator.set(route: .kycReview)
                case .open:
                  onboardingFlowCoordinator.set(route: .document)
                case .reviewInProgress:
                  onboardingFlowCoordinator.set(route: .documentInReview)
                }
              } else {
                if documents.requestedDocuments.isEmpty {
                  onboardingFlowCoordinator.set(route: .kycReview)
                } else {
                  onboardingFlowCoordinator.set(route: .unclear("Required Document Unknown: \(documents.requestedDocuments.debugDescription)"))
                }
              }
            } else if states.contains(OnboardingMissingStep.dashboardReview) {
              onboardingFlowCoordinator.set(route: .kycReview)
            } else if states.contains(OnboardingMissingStep.zeroHashAccount) {
              onboardingFlowCoordinator.set(route: .zeroHash)
            } else if states.contains(OnboardingMissingStep.accountReject) {
              onboardingFlowCoordinator.set(route: .accountReject)
            } else if states.contains(OnboardingMissingStep.primaryPersonKYCApprove) {
              onboardingFlowCoordinator.set(route: .kycReview)
            } else {
              onboardingFlowCoordinator.set(route: .unclear(states.compactMap({ $0.rawValue }).joined()))
            }
          }
        }
      } else {
        self.onboardingFlowCoordinator.set(route: .dashboard)
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
  // swiftlint:enable function_body_length

  private func handleQuestionCase() async {
    do {
      let questionsEncrypt = try await netspendRepository.getQuestion(sessionId: accountDataManager.sessionID)
      if let usersession = netspendDataManager.sdkSession, let questionsDecode = questionsEncrypt.decodeData(session: usersession) {
        let questionsEntity = QuestionsEntity.mapObj(questionsDecode)
        onboardingFlowCoordinator.set(route: .question(questionsEntity))
      } else {
        onboardingFlowCoordinator.set(route: .kycReview)
      }
    } catch {
      onboardingFlowCoordinator.set(route: .kycReview)
      log.debug(error)
    }
  }
}
