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
import LFLocalizable

@MainActor
final class VerificationCodeViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.onboardingRepository) var onboardingRepository
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.onboardingFlowCoordinator) var onboardingFlowCoordinator
  @LazyInjected(\.nsPersionRepository) var nsPersionRepository
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  @LazyInjected(\.rewardDataManager) var rewardDataManager
  @LazyInjected(\.customerSupportService) var customerSupportService
  @LazyInjected(\.analyticsService) var analyticsService
  
  @Published var isNavigationToWelcome: Bool = false
  @Published var isResendButonTimerOn = false
  @Published var isShowText: Bool = true
  @Published var isShowLoading: Bool = false
  @Published var formatPhoneNumber: String = ""
  @Published var otpCode: String = ""
  @Published var timeString: String = ""
  @Published var toastMessage: String?
  @Published var errorMessage: String?
  @Published var navigation: Navigation?
  
  let requireAuth: [RequiredAuth]
  var cancellables: Set<AnyCancellable> = []
  lazy var requestOtpUseCase: RequestOTPUseCaseProtocol = {
    RequestOTPUseCase(repository: onboardingRepository)
  }()
  lazy var loginUseCase: LoginUseCaseProtocol = {
    LoginUseCase(repository: onboardingRepository)
  }()
  
  init(phoneNumber: String, requireAuth: [RequiredAuth]) {
    self.requireAuth = requireAuth
    formatPhoneNumber = Constants.Default.regionCode.rawValue + phoneNumber
    performAutoGetTwilioMessagesIfNeccessary()
  }
}

  // MARK: API
extension VerificationCodeViewModel {
  func handleAfterGetOTP(formatPhoneNumber: String, code: String) {
    guard !isShowLoading else { return }
    isShowLoading = true
    if requireAuth.count == 1 && requireAuth.contains(where: { $0 == .otp }) {
      analyticsService.track(event: AnalyticsEvent(name: .viewSignUpLogin))
      performVerifyOTPCode(formatPhoneNumber: formatPhoneNumber, code: code)
    } else {
      isShowLoading = false
      let isSSNCheck = requireAuth.contains(where: { $0 == .ssn })
      let isPassportCheck = requireAuth.contains(where: { $0 == .passport })
      let identityVerificationKind: IdentityVerificationCodeViewModel.Kind? = isSSNCheck
      ? .ssn
      : isPassportCheck ? .passport : nil
      if let kind = identityVerificationKind {
        navigation = .identityVerificationCode(formatPhoneNumber, self.otpCode, kind)
      }
    }
  }
  
  func performVerifyOTPCode(formatPhoneNumber: String, code: String) {
    Task {
    #if DEBUG
      let start = CFAbsoluteTimeGetCurrent()
    #endif
      do {
        _ = try await loginUseCase.execute(phoneNumber: formatPhoneNumber, otpCode: code, lastID: .empty)
        accountDataManager.update(phone: formatPhoneNumber)
        accountDataManager.stored(phone: formatPhoneNumber)
        
        if LFUtilities.charityEnabled { // we enable showRoundUpForCause after user login
          UserDefaults.showRoundUpForCause = true
        }
        
        try await initNetSpendSession()
        await checkOnboardingState()
        
        analyticsService.set(params: ["phoneVerified": true])
        analyticsService.track(event: AnalyticsEvent(name: .loggedIn))
        
        self.isShowLoading = false
        
      } catch {
        analyticsService.set(params: ["phoneVerified": false])
        analyticsService.track(event: AnalyticsEvent(name: .phoneVerificationError))
        handleError(error: error)
      }
    #if DEBUG
      let diff = CFAbsoluteTimeGetCurrent() - start
      log.debug("Took \(diff) seconds")
    #endif
    }
  }
  
  func performGetOTP(formatPhoneNumber: String) {
    Task {
      defer { isShowLoading = false }
      isShowLoading = true
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
      }
      .store(in: &cancellables)
  }
  
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }
}

  // MARK: View Helpers
extension VerificationCodeViewModel {
  func onChangedOTPCode() {
    if otpCode.count == Constants.MaxCharacterLimit.verificationLimit.value {
      handleAfterGetOTP(formatPhoneNumber: formatPhoneNumber, code: otpCode)
    }
  }
  
  func resendOTP() {
    performGetOTP(formatPhoneNumber: formatPhoneNumber)
  }
}

  // MARK: Private Functions
private extension VerificationCodeViewModel {
  func handleError(error: Error) {
    isShowLoading = false
    guard let code = error.asErrorObject?.code else {
      toastMessage = error.localizedDescription
      return
    }
    switch code {
    case Constants.ErrorCode.userInactive.value:
      onboardingFlowCoordinator.set(route: .accountLocked)
    case Constants.ErrorCode.credentialsInvalid.value:
      toastMessage = LFLocalizable.VerificationCode.OtpInvalid.message
    default:
      toastMessage = error.localizedDescription
    }
  }
  
  func initNetSpendSession() async throws {
    log.info("<<<<<<<<<<<<<< Refresh NetSpend Session >>>>>>>>>>>>>>>")
    let token = try await nsPersionRepository.clientSessionInit()
    netspendDataManager.update(jwkToken: token)
    
    let sessionConnectWithJWT = await nsPersionRepository.establishingSessionWithJWKSet(jwtToken: token)
    
    guard let deviceData = sessionConnectWithJWT?.deviceData else { return }
    
    let establishPersonSession = try await nsPersionRepository.establishPersonSession(deviceData: EstablishSessionParameters(encryptedData: deviceData))

    netspendDataManager.update(serverSession: establishPersonSession as? APIEstablishedSessionData)
    accountDataManager.stored(sessionID: establishPersonSession.id)
    
    let userSessionAnonymous = try nsPersionRepository.createUserSession(establishingSession: sessionConnectWithJWT, encryptedData: establishPersonSession.encryptedData)
    netspendDataManager.update(sdkSession: userSessionAnonymous)
  }
  
  func checkUserIsValid() -> Bool {
    accountDataManager.sessionID.isEmpty == false
  }
  
  func handleDataUser(user: LFUser) {
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
  func checkOnboardingState() async {
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
              let questionsEncrypt = try await nsPersionRepository.getQuestion(sessionId: accountDataManager.sessionID)
              if let usersession = netspendDataManager.sdkSession, let questionsDecode = (questionsEncrypt as? APIQuestionData)?.decodeData(session: usersession) {
                let questionsEntity = QuestionsEntity.mapObj(questionsDecode)
                onboardingFlowCoordinator.set(route: .question(questionsEntity))
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
}

// MARK: Types
extension VerificationCodeViewModel {
  enum Navigation {
    case identityVerificationCode(String, String, IdentityVerificationCodeViewModel.Kind)
  }
}
