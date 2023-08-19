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

@MainActor
final class VerificationCodeViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.onboardingRepository) var onboardingRepository
  @LazyInjected(\.onboardingFlowCoordinator) var onboardingFlowCoordinator
  @LazyInjected(\.netspendRepository) var netspendRepository
  @LazyInjected(\.netspendDataManager) var netspendDataManager
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
      do {
        _ = try await loginUseCase.execute(phoneNumber: formatPhoneNumber, code: code)
        accountDataManager.update(phone: formatPhoneNumber)
        accountDataManager.stored(phone: formatPhoneNumber)
        
        intercomService.loginIdentifiedUser(userAttributes: IntercomService.UserAttributes(phone: formatPhoneNumber))
        
        let token = try await netspendRepository.clientSessionInit()
        netspendDataManager.update(jwkToken: token)
        
        let sessionConnectWithJWT = await netspendRepository.establishingSessionWithJWKSet(jwtToken: token)
        
        guard let deviceData = sessionConnectWithJWT?.deviceData else { return }
        
        let establishPersonSession = try await netspendRepository.establishPersonSession(deviceData: EstablishSessionParameters(encryptedData: deviceData))
        netspendDataManager.update(serverSession: establishPersonSession)
        accountDataManager.stored(sessionID: establishPersonSession.id)
        
        let userSessionAnonymous = try netspendRepository.createUserSession(establishingSession: sessionConnectWithJWT, encryptedData: establishPersonSession.encryptedData)
        netspendDataManager.update(sdkSession: userSessionAnonymous)
        
        checkOnboardingState { self.isShowLoading = false }
        
      } catch {
        self.isShowLoading = false
        toastMessage = error.localizedDescription
        log.error(error)
      }
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
      //guard DemoAccountsHelper.shared.shouldInterceptSms(number: formatPhoneNumber) else { return }
    DemoAccountsHelper.shared.getTwilioMessages(for: formatPhoneNumber)
      .sink { [weak self] code in
        guard let self else { return }
        log.debug(code ?? "performGetTwilioMessagesIfNeccessary not found")
        guard let code = code else { return }
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
  private func checkOnboardingState(onCompletion: @escaping () -> Void) {
    Task { @MainActor in
      defer { onCompletion() }
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
            } else if states.contains(OnboardingMissingStep.cardProvision) {
              //TODO: We implement late
            } else if states.contains(OnboardingMissingStep.accountReject) {
              onboardingFlowCoordinator.set(route: .accountReject)
            }
          }
        }
      } catch {
        onboardingFlowCoordinator.set(route: .welcome)
        log.error(error.localizedDescription)
      }
    }
  }
  
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
  
  private func handleUpDocumentCase() async {
    do {
      let documents = try await netspendRepository.getDocuments(sessionId: accountDataManager.sessionID)
      netspendDataManager.update(documentData: documents)
      onboardingFlowCoordinator.set(route: .document)
    } catch {
      onboardingFlowCoordinator.set(route: .kycReview)
      log.debug(error)
    }
  }
}
