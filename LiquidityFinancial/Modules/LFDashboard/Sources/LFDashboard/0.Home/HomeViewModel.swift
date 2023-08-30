import UIKit
import Foundation
import Factory
import OnboardingData
import AccountData
import LFUtilities
import DevicesData
import LFAccountOnboarding
import OnboardingDomain
import AccountDomain
import NetSpendData
import Combine
import LFBank

@MainActor
public final class HomeViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.devicesRepository) var devicesRepository
  @LazyInjected(\.onboardingRepository) var onboardingRepository
  @LazyInjected(\.netspendRepository) var netspendRepository
  
  @LazyInjected(\.pushNotificationService) var pushNotificationService
  @LazyInjected(\.onboardingFlowCoordinator) var onboardingFlowCoordinator
  
  @Published var isShowGearButton: Bool = false
  @Published var tabSelected: TabOption = .cash
  @Published var navigation: Navigation?
  @Published var popup: Popup?
  
  @Published var isLoading: Bool = false
  @Published var toastMessage: String?

  public init() {
    initData()
    accountDataManager.userCompleteOnboarding = true
    checkGoTransactionDetail()
  }
}

// MARK: - API
extension HomeViewModel {
  private func apiFetchUser() {
    if let userID = accountDataManager.userInfomationData.userID, userID.isEmpty == false {
      return
    }
    Task {
      do {
        let user = try await accountRepository.getUser()
        accountDataManager.storeUser(user: user)
        if let firstName = user.firstName, let lastName = user.lastName {
          accountDataManager.update(fullName: firstName + " " + lastName)
        }
      } catch {
        log.error(error.localizedDescription)
      }
    }
  }
  
  func apiFetchOnboardingState() {
    Task { @MainActor in
      do {
        async let fetchOnboardingState = onboardingRepository.getOnboardingState(sessionId: accountDataManager.sessionID)
        
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
              log.info("Current OnboardingState in Dashboard is wrong step: zeroHashAccount")
            } else if states.contains(OnboardingMissingStep.accountReject) {
              onboardingFlowCoordinator.set(route: .accountReject)
            } else if states.contains(OnboardingMissingStep.primaryPersonKYCApprove) {
              onboardingFlowCoordinator.set(route: .kycReview)
            } else {
              onboardingFlowCoordinator.set(route: .unclear(states.compactMap({ $0.rawValue }).joined()))
            }
          }
        }
      } catch {
        log.error(error.localizedDescription)
      }
    }
  }
}

// MARK: API init data tab content
extension HomeViewModel {
  
  func initData() {
    apiFetchUser()
    apiFetchOnboardingState()
  }
  
}

// MARK: Notifications
extension HomeViewModel {

  func onAppear() {
    checkShouldShowNotification()
    checkGoTransactionDetail()
  }
  
  func checkGoTransactionDetail() {
    guard
      let id = pushNotificationService.selectedTransactionId,
      let type = pushNotificationService.selectedTransactionType else {
      return
    }
    openTransactionId(id, type: type)
  }
  
  func checkShouldShowNotification() {
    Task { @MainActor in
      do {
        let status = try await pushNotificationService.notificationSettingStatus()
        if status == .notDetermined {
          if UserDefaults.didShowPushTokenPopup {
            return
          }
          popup = .notifications
          UserDefaults.didShowPushTokenPopup = true
        } else if status == .authorized {
          self.pushFCMTokenIfNeed()
        }
      } catch {
        log.error(error)
      }
    }
  }
  
  func pushFCMTokenIfNeed() {
    Task { @MainActor in
      do {
        let token = try await pushNotificationService.fcmToken()
        if token == UserDefaults.lastestFCMToken {
          return
        }
        let response = try await devicesRepository.register(deviceId: LFUtility.deviceId, token: token)
        if response.success {
          UserDefaults.lastestFCMToken = token
        }
      } catch {
        log.error(error)
      }
    }
  }
  
  func notificationsPopupAction() {
    clearPopup()
    Task { @MainActor in
      do {
        let success = try await pushNotificationService.requestPermission()
        if success {
          self.pushFCMTokenIfNeed()
        }
      } catch {
        log.error(error)
      }
    }
  }

  func clearPopup() {
    popup = nil
  }
  
  func openTransactionId(_ id: String, type: String) {
    let isCrypto = type == "crypto"
    Task { @MainActor in
      do {
        let currencyType = isCrypto ? Constants.CurrencyType.crypto.rawValue : Constants.CurrencyType.fiat.rawValue
        let accounts = try await self.accountRepository.getAccount(currencyType: currencyType)
        guard let account = accounts.first else {
          return
        }
        navigation = .transactionDetail(id: id, accountId: account.id)
        pushNotificationService.clearSelection()
      } catch {
        log.error(error.localizedDescription)
      }
    }
  }
}

// MARK: - View Helpers
extension HomeViewModel {
  func onSelectedTab(tab: TabOption) {
    tabSelected = tab
  }
  
  func onClickedProfileButton() {
    navigation = .profile
  }
  
  func onClickedGearButton() {
    
  }
}

// MARK: - Types
extension HomeViewModel {
  enum Navigation {
    case profile
    case transactionDetail(id: String, accountId: String)
  }
  
  enum Popup {
    case notifications
  }
}
