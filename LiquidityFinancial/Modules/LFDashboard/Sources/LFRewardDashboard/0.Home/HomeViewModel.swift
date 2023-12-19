import UIKit
import Combine
import Factory
import AccountData
import AccountDomain
import LFUtilities
import RewardData
import RewardDomain
import LFRewards
import DevicesData
import Services
import DevicesDomain
import AccountService
import SolidData
import SolidDomain
import ExternalFundingData
import LFFeatureFlags
import BiometricsManager
import LFLocalizable
import SwiftUI

@MainActor
public final class HomeViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.biometricsManager) var biometricsManager
  @LazyInjected(\.rewardDataManager) var rewardDataManager
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.onboardingRepository) var onboardingRepository
  @LazyInjected(\.devicesRepository) var devicesRepository
  @LazyInjected(\.externalFundingRepository) var externalFundingRepository
  @LazyInjected(\.pushNotificationService) var pushNotificationService
  @LazyInjected(\.customerSupportService) var customerSupportService
  
  @Injected(\.solidAccountRepository) var solidAccountRepository
  @Injected(\.solidExternalFundingRepository) var solidExternalFundingRepository
  @Injected(\.fiatAccountService) var fiatAccountService
  @Injected(\.externalFundingDataManager) var externalFundingDataManager
  
  lazy var solidGetWireTransfer: SolidGetWireTranferUseCaseProtocol = {
    SolidGetWireTranferUseCase(repository: solidExternalFundingRepository)
  }()
  
  lazy var solidGetLinkedSourcesUseCase: SolidGetLinkedSourcesUseCaseProtocol = {
    SolidGetLinkedSourcesUseCase(repository: solidExternalFundingRepository)
  }()
  
  lazy var unlinkContactUseCase: SolidUnlinkContactUseCaseProtocol = {
    SolidUnlinkContactUseCase(repository: solidExternalFundingRepository)
  }()
  
  lazy var deviceRegisterUseCase: DeviceRegisterUseCaseProtocol = {
    DeviceRegisterUseCase(repository: devicesRepository)
  }()
  
  var enableMultiFactorAuthenticationFlag: Bool {
    switch LFUtilities.target {
    case .PrideCard:
      return LFFeatureFlagContainer.enableMultiFactorAuthenticationFlagPrideCard.value
    case .CauseCard:
      return LFFeatureFlagContainer.enableMultiFactorAuthenticationFlagCauseCard.value
    default:
      return false
    }
  }
  
  @Published var biometricType: BiometricType = .none
  @Published var tabSelected: TabOption = .cash
  @Published var navigation: Navigation?
  @Published var tabOptions: [TabOption] = [.cash, .rewards, .account]
  @Published var popupQueue: [ActionRequestPopup] = []
  @Published var popup: Popup?
  @Published var blockingPopup: BlockingPopup?
  @Published var toastMessage: String?
  @Published var shouldShowBiometricsFallback: Bool = false
  @Published var isShowingRequiredActionPrompt: Bool = false

  private var subscribers: Set<AnyCancellable> = []
  
  private var isFristLoad: Bool = true
  private var hadPushToken: Bool = false
  
  public init(tabOptions: [TabOption]) {
    if let reward = rewardDataManager.currentSelectReward {
      buildTabOption(with: reward)
    } else {
      self.tabOptions = tabOptions
    }
    accountDataManager.userCompleteOnboarding = true
    initData()
    checkBiometricsCapability()
    authenticateWithBiometrics()
    observeActionRequestPopupChange()
  }
  
  var showGearButton: Bool {
    tabSelected == .rewards || tabSelected == .donation
  }
  
  var showSearchButton: Bool {
    tabSelected == .causes
  }
  
  func onAppear() {
    logincustomerSupportService()
    checkShouldShowNotification()
  }
}

// MARK: - Private
private extension HomeViewModel {
  func initData() {
    apiFetchUser()
    refreshLinkedSources()
    handleSelectRewardChange()
    handleSelectedFundraisersSuccess()
    handleFCMTokenRefresh()
  }
  
  func logincustomerSupportService() {
    guard customerSupportService.isLoginIdentifiedSuccess == false else { return }
    var userAttributes: UserAttributes
    if let userID = accountDataManager.userInfomationData.userID {
      userAttributes = UserAttributes(phone: accountDataManager.phoneNumber, userId: userID, email: accountDataManager.userEmail)
    } else {
      userAttributes = UserAttributes(phone: accountDataManager.phoneNumber, email: accountDataManager.userEmail)
    }
    customerSupportService.loginIdentifiedUser(userAttributes: userAttributes)
  }
  
  func handleFCMTokenRefresh() {
    NotificationCenter.default.publisher(for: .didReceiveRegistrationToken)
      .sink { [weak self] _ in
        self?.apiPushdeviceRegister()
      }
      .store(in: &subscribers)
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
      .dropFirst()
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
    let noneRewardList: [TabOption] = [.cash, .noneReward, .account]
    let donationList: [TabOption] = [.cash, .donation, .causes, .account]
    switch reward.rawString {
    case UserRewardType.cashBack.rawValue:
      tabOptions = rewardList
    case UserRewardType.donation.rawValue:
      tabOptions = donationList
    case UserRewardType.none.rawValue:
      tabOptions = noneRewardList
    default:
      tabOptions = noneRewardList
    }
  }
  
  func updateTabSelected(with reward: SelectRewardTypeEntity) {
    guard isFristLoad == false else { return }
    switch reward.rawString {
    case UserRewardType.cashBack.rawValue:
      tabSelected = .rewards
    case UserRewardType.donation.rawValue:
      tabSelected = .donation
    case UserRewardType.none.rawValue:
      tabSelected = .rewards
    default:
      tabSelected = .cash
    }
  }
  
  func checkBiometricsCapability() {
    biometricsManager.checkBiometricsCapability(purpose: .enable)
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: { completion in
        switch completion {
        case .finished:
          log.debug("Biometrics capability check completed.")
        case .failure(let error):
          log.error("Biometrics error: \(error.localizedDescription)")
        }
      }, receiveValue: { [weak self] result in
        guard let self else { return }
        self.biometricType = result.type
      })
      .store(in: &subscribers)
  }
  
  func openDeviceSettings() {
    if let url = URL(string: UIApplication.openSettingsURLString) {
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
  }
  
  func showNextActionRequestPopup() {
    guard let nextPopup = popupQueue.first else {
      return
    }
    switch nextPopup {
    case .notifications:
      popup = .notifications
    case .passwordEnhancedSecurity:
      blockingPopup = .passwordEnhancedSecurity
    case .biometricEnhancedSecurity:
      popup = .biometricEnhancedSecurity
    }
  }
  
  func observeActionRequestPopupChange() {
    Publishers.CombineLatest($popupQueue, $isShowingRequiredActionPrompt)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] _ in
        guard let self, !self.isShowingRequiredActionPrompt else {
          return
        }
        self.showNextActionRequestPopup()
      }
      .store(in: &subscribers)
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
        showEnhanceSecurityPopupIfNeed()
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

  func apiPushdeviceRegister() {
    Task { @MainActor in
      do {
        let token = try await pushNotificationService.fcmToken()
        let response = try await deviceRegisterUseCase.execute(deviceId: LFUtilities.deviceId, token: token)
        if response.success {
          hadPushToken = true
          UserDefaults.lastestFCMToken = token
        }
      } catch {
        log.error(error)
      }
    }
  }
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
  
  func checkShouldShowNotification() {
    Task { @MainActor in
      defer { showEnhanceSecurityPopupIfNeed() }
      do {
        let status = try await pushNotificationService.notificationSettingStatus()
        if status == .notDetermined {
          if UserDefaults.didShowPushTokenPopup {
            return
          }
          popupQueue.append(.notifications)
          UserDefaults.didShowPushTokenPopup = true
        } else if status == .authorized {
          self.pushFCMTokenIfNeed()
        }
      } catch {
        log.error(error)
      }
    }
  }
  
  func showEnhanceSecurityPopupIfNeed() {
    guard let userID = accountDataManager.userInfomationData.userID, !userID.isEmpty,
          enableMultiFactorAuthenticationFlag,
          blockingPopup != .passwordEnhancedSecurity
    else {
      UserDefaults.isStartedWithLoginFlow = false
      return
    }
    
    let userData = accountDataManager.userInfomationData as? UserInfomationData
    let missingSteps = userData?.missingStepsEnum ?? []
    
    // Only show the biometric enhance security popup if it is a new session
    let isShowBiometricSecurityPopup = !accountDataManager.isBiometricUsageEnabled && UserDefaults.isStartedWithLoginFlow
    
    UserDefaults.isStartedWithLoginFlow = false
    
    if missingSteps.contains(.createPassword) {
      popupQueue.append(.passwordEnhancedSecurity)
      UserDefaults.isStartedWithLoginFlow = true
    } else if isShowBiometricSecurityPopup {
      popupQueue.append(.biometricEnhancedSecurity)
    }
  }
  
  func pushFCMTokenIfNeed() {
    guard hadPushToken == false else { return }
    apiPushdeviceRegister()
  }
  
  func notificationsPopupAction() {
    Task { @MainActor in
      // Need to dismiss current popup to show device alert
      isShowingRequiredActionPrompt = true
      clearPopup()
      
      do {
        let success = try await pushNotificationService.requestPermission()
        self.isShowingRequiredActionPrompt = false
        if success {
          self.pushFCMTokenIfNeed()
        }
      } catch {
        log.error(error)
      }
    }
  }
  
  func enhancedSecurityPopupAction() {
    clearBlockingPopup()
    navigation = .createPassword
  }
  
  func setupBiometricSecurity() {
    popup = .biometricSetup
  }

  func clearPopup() {
    switch popup {
    case .notifications:
      popupQueue.removeAll { $0 == .notifications }
    case .biometricEnhancedSecurity:
      popupQueue.removeAll { $0 == .biometricEnhancedSecurity }
    default: break
    }
    
    popup = nil
  }
  
  func clearBlockingPopup() {
    switch blockingPopup {
    case .passwordEnhancedSecurity:
      popupQueue.removeAll { $0 == .passwordEnhancedSecurity }
    default: break
    }
    
    blockingPopup = nil
  }
  
  func openTransactionId(_ id: String, accountId: String) {
    Task { @MainActor in
      navigation = .transactionDetail(id: id, accountId: accountId)
    }
  }
}

// MARK: - LinkedSources
extension HomeViewModel {
  func refreshLinkedSources() {
    Task { @MainActor in
      do {
        try await fetchSolidLinkedSources()
      } catch {
        toastMessage = error.localizedDescription
        log.error(error.localizedDescription)
      }
    }
  }
  
  private func getFiatAccounts() async throws -> [AccountModel] {
    let accounts = try await fiatAccountService.getAccounts()
    self.accountDataManager.addOrUpdateAccounts(accounts)
    return accounts
  }
  
  private func removeUnknowContactSources(_ sources: [SolidContactEntity]) async {
    let contactModel = sources.compactMap({ $0 as? APISolidContact })
    await contactModel.concurrentForEach { source in
      if APISolidContactType(rawValue: source.type) == nil {
        _ = try? await self.unlinkContactUseCase.execute(id: source.solidContactId)
      }
    }
  }
  
  private func fetchSolidLinkedSources() async throws {
    var account = self.accountDataManager.fiatAccounts.first
    if account == nil {
      account = try await getFiatAccounts().first
    }
    guard let account = account else {
      return
    }
    let response = try await self.solidGetLinkedSourcesUseCase.execute(accountID: account.id)
    var unknownSources: [SolidContactEntity] = []
    let contacts = response.compactMap({ (data: SolidContactEntity) -> LinkedSourceContact? in
      guard let type = APISolidContactType(rawValue: data.type) else {
        unknownSources.append(data)
        return nil
      }
      let sourceType: LinkedSourceContactType = type == .externalBank ? .bank : .card
      return LinkedSourceContact(name: data.name, last4: data.last4, sourceType: sourceType, sourceId: data.solidContactId)
    })
    self.externalFundingDataManager.storeLinkedSources(contacts)
    await self.removeUnknowContactSources(unknownSources)
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
  
  func authenticateWithBiometrics() {
    let isEnableAuthenticateWithBiometrics = UserDefaults.isBiometricUsageEnabled && !UserDefaults.isStartedWithLoginFlow

    if enableMultiFactorAuthenticationFlag, isEnableAuthenticateWithBiometrics {
      biometricsManager.performBiometricsAuthentication(purpose: .authentication)
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { [weak self] completion in
          guard let self else { return }
          switch completion {
          case .finished:
            log.debug("Biometrics capabxility check completed.")
          case .failure(let error):
            log.error("Biometrics error: \(error.localizedDescription)")
            // In all cases of authentication failure, we will take the user to the biometrics backup screen
            self.shouldShowBiometricsFallback = true
          }
        }, receiveValue: { _ in })
        .store(in: &subscribers)
    }
  }
  
  func allowBiometricAuthentication() {
    clearPopup()
    biometricsManager.performBiometricsAuthentication(purpose: .enable)
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: { [weak self] completion in
        guard let self else { return }
        switch completion {
        case .finished:
          log.debug("Biometrics capabxility check completed.")
        case .failure(let error):
          self.handleBiometricAuthenticationError(error: error)
        }
      }, receiveValue: { [weak self] result in
        guard let self else { return }
        self.accountDataManager.isBiometricUsageEnabled = result.isEnabled
      })
      .store(in: &subscribers)
  }
  
  func handleBiometricAuthenticationError(error: BiometricError) {
    accountDataManager.isBiometricUsageEnabled = false
    switch error {
    case .biometryNotAvailable:
      openDeviceSettings()
    case .biometryLockout:
      popup = .biometricsLockout
    default:
      break
    }
  }
}

// MARK: - Types
extension HomeViewModel {
  enum Navigation {
    case searchCauses
    case editRewards
    case profile
    case transactionDetail(id: String, accountId: String)
    case createPassword
  }
  
  enum Popup {
    case notifications
    case biometricEnhancedSecurity
    case biometricSetup
    case biometricsLockout
  }
  
  enum BlockingPopup {
    case passwordEnhancedSecurity
  }
  
  enum ActionRequestPopup {
    case notifications
    case passwordEnhancedSecurity
    case biometricEnhancedSecurity
  }
}
