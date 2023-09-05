import UIKit
import Foundation
import Factory
import OnboardingData
import AccountData
import AccountDomain
import LFUtilities
import RewardData
import RewardDomain
import LFRewards
import Combine
import LFAccountOnboarding
import OnboardingDomain
import DevicesData

@MainActor
public final class HomeViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  @LazyInjected(\.rewardDataManager) var rewardDataManager
  
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.onboardingRepository) var onboardingRepository
  @LazyInjected(\.netspendRepository) var netspendRepository
  @LazyInjected(\.devicesRepository) var devicesRepository
  @LazyInjected(\.externalFundingRepository) var externalFundingRepository
  
  @LazyInjected(\.pushNotificationService) var pushNotificationService
  @LazyInjected(\.onboardingFlowCoordinator) var onboardingFlowCoordinator
  
  @Published var tabSelected: TabOption = .cash
  @Published var navigation: Navigation?
  @Published var tabOptions: [TabOption] = [.cash, .rewards, .account]
  @Published var popup: Popup?
  @Published var toastMessage: String?
  
  private var subscribers: Set<AnyCancellable> = []
  
  private var isFristLoad: Bool = true
  
  public init(tabOptions: [TabOption]) {
    self.tabOptions = tabOptions
    accountDataManager.userCompleteOnboarding = true
    initData()
  }
  
  var showGearButton: Bool {
    tabSelected == .rewards || tabSelected == .donation
  }
  
  var showSearchButton: Bool {
    tabSelected == .donation || tabSelected == .causes
  }
}

// MARK: - Private
private extension HomeViewModel {
  func initData() {
    apiFetchUser()
    apiFetchOnboardingState()
    handleSelectRewardChange()
    handleSelectedFundraisersSuccess()
    getListConnectedAccount()
  }
  
  func handleSelectedFundraisersSuccess() {
    NotificationCenter.default.publisher(for: .selectedFundraisersSuccess)
      .delay(for: 0.55, scheduler: RunLoop.main)
      .sink { [weak self] _ in
        guard self?.rewardDataManager.fundraisersDetail != nil else { return }
        self?.tabSelected = .donation
      }
      .store(in: &subscribers)
  }
  
  func handleSelectRewardChange() {
    rewardDataManager
      .selectRewardChangedEvent
      .receive(on: DispatchQueue.main)
      .sink { [weak self] reward in
        self?.buildTabOption(with: reward)
        self?.updateTabSelected(with: reward)
        self?.isFristLoad = false
      }
      .store(in: &subscribers)
  }
  
  func buildTabOption(with reward: SelectRewardTypeEntity) {
    let rewardList: [TabOption] = [.cash, .rewards, .account]
    let donationList: [TabOption] = [.cash, .donation, .causes, .account]
    switch reward.rawString {
    case UserRewardType.cashBack.rawValue:
      tabOptions = rewardList
    case UserRewardType.donation.rawValue:
      tabOptions = donationList
    default:
      tabOptions = rewardList
    }
  }
  
  func updateTabSelected(with reward: SelectRewardTypeEntity) {
    guard isFristLoad == false else { return }
    switch reward.rawString {
    case UserRewardType.cashBack.rawValue:
      tabSelected = .rewards
    case UserRewardType.donation.rawValue:
      tabSelected = .donation
    default:
      tabSelected = .cash
    }
  }
}

// MARK: - API User
private extension HomeViewModel {
  func apiFetchUser() {
    if let userID = accountDataManager.userInfomationData.userID, userID.isEmpty == false {
      return
    }
    Task {
      do {
        let user = try await accountRepository.getUser()
        handleDataUser(user: user)
      } catch {
        log.error(error.localizedDescription)
      }
    }
  }
  
  func handleDataUser(user: LFUser) {
    accountDataManager.storeUser(user: user)
    if let rewardType = APIRewardType(rawValue: user.userRewardType ?? "") {
      rewardDataManager.update(currentSelectReward: rewardType)
    }
    if let userSelectedFundraiserID = user.userSelectedFundraiserId {
      rewardDataManager.update(selectedFundraiserID: userSelectedFundraiserID)
    }
    if let firstName = user.firstName, let lastName = user.lastName {
      accountDataManager.update(fullName: firstName + " " + lastName)
    }
  }
  
  // swiftlint:disable function_body_length
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
  // swiftlint:enable function_body_length

}

// MARK: Notifications
extension HomeViewModel {
  func checkGoTransactionDetail() {
    guard let event = pushNotificationService.event else {
      return
    }
    switch event {
    case let .transaction(id, accountId):
      openTransactionId(id, accountId: accountId)
    }
  }
  
  func appearOperations() {
    checkShouldShowNotification()
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
  
  func openTransactionId(_ id: String, accountId: String) {
    Task { @MainActor in
      navigation = .transactionDetail(id: id, accountId: accountId)
    }
  }
  
  func getListConnectedAccount() {
    Task { @MainActor in
      do {
        let sessionID = self.accountDataManager.sessionID
        async let response = self.externalFundingRepository.getLinkedAccount(sessionId: sessionID)
        let linkedSources = try await response.linkedSources
        self.accountDataManager.storeLinkedSources(linkedSources)
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
    navigation = .editRewards
  }
  
  func onClickedSearchButton() {
    navigation = .searchCauses
  }
}

// MARK: - Types
extension HomeViewModel {
  enum Navigation {
    case searchCauses
    case editRewards
    case profile
    case transactionDetail(id: String, accountId: String)
  }
  
  enum Popup {
    case notifications
  }
}
