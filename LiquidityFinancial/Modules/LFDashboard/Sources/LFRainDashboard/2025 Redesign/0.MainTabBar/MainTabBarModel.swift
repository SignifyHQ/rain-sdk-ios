import UIKit
import RainFeature
import Foundation
import Factory
import AccountData
import LFUtilities
import DevicesData
import AccountDomain
import RainData
import RainDomain
import Combine
import Services
import DevicesDomain
import BiometricsManager

//swiftlint:disable file_length
@MainActor
final class MainTabBarModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.biometricsManager) var biometricsManager
  @LazyInjected(\.featureFlagManager) var featureFlagManager
  
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.devicesRepository) var devicesRepository
  @LazyInjected(\.rainRepository) var rainRepository
  @LazyInjected(\.rainCardRepository) var rainCardRepository

  @LazyInjected(\.pushNotificationService) var pushNotificationService
  @LazyInjected(\.analyticsService) var analyticsService
  @LazyInjected(\.customerSupportService) var customerSupportService
  
  @Published var isShowGearButton: Bool = false
  @Published var shouldShowBiometricsFallback: Bool = false
  @Published var tabSelected: TabItem = .cash
  @Published var tabItems: [TabItem] = []
  @Published var navigation: Navigation?
  @Published var popup: Popup?
  @Published var isLoading: Bool = false
  @Published var toastMessage: String?

  private var popupQueue: [Popup] = [.notifications]
  private var hadPushToken: Bool = false
  private var subscribers: Set<AnyCancellable> = []

  lazy var deviceRegisterUseCase: DeviceRegisterUseCaseProtocol = {
    DeviceRegisterUseCase(repository: devicesRepository)
   }()
  
  lazy var shouldShowPopupUseCase: ShouldShowPopupUseCaseProtocol = {
    ShouldShowPopupUseCase(repository: accountRepository)
  }()
  
  lazy var savePopupShownUseCaseProtocol: SavePopupShownUseCaseProtocol = {
    SavePopupShownUseCase(repository: accountRepository)
  }()
  
  lazy var rainGetPending3dsChallengesUseCase: RainGetPending3dsChallengesUseCaseProtocol = {
    RainGetPending3dsChallengesUseCase(repository: rainCardRepository)
  }()
  
  lazy var rainMake3dsChallengeDecisionUseCase: RainMake3dsChallengeDecisionUseCaseProtocol = {
    RainMake3dsChallengeDecisionUseCase(repository: rainCardRepository)
  }()
  
  let accountViewModel: MyAccountViewModel
  let dashboardRepository: DashboardRepository
  
  init(tabItems: [TabItem]) {
    self.dashboardRepository = DashboardRepository()
    self.accountViewModel = MyAccountViewModel(dashboardRepository: dashboardRepository)
    self.tabItems = tabItems
    
    self.dashboardRepository.toastMessage = { [weak self] message in
      guard let self else { return }
      self.toastMessage = message
    }
    
    initData()
    accountDataManager.userCompleteOnboarding = true
    checkGoTransactionDetail()
    UserDefaults.isStartedWithLoginFlow = false
    notificationObserver()
  }
}

// MARK: Handle UI/UX
extension MainTabBarModel {
  func initData() {
    apiFetchUser()
    
    // Check if we need to show the Apple Pay popup
    checkShouldShowApplePayPopup()
    
    // Check if we need to show the popup for special experience
    //checkShouldShowSpecialExperiencePopup()
  }
  
  func onAppear() {
    checkShouldShowNotification()
    checkGoTransactionDetail()
    loginCustomerSupportService()
    dashboardRepository.onAppear()
    fetchPending3DSChallenged()
  }
  
  func loginCustomerSupportService() {
    guard customerSupportService.isLoginIdentifiedSuccess == false else { return }
    var userAttributes: UserAttributes
    if let userID = accountDataManager.userInfomationData.userID {
      userAttributes = UserAttributes(phone: accountDataManager.phoneNumber, userId: userID, email: accountDataManager.userEmail)
    } else {
      userAttributes = UserAttributes(phone: accountDataManager.phoneNumber, email: accountDataManager.userEmail)
    }
    customerSupportService.loginIdentifiedUser(userAttributes: userAttributes)
  }
  
  private func checkShouldShowApplePayPopup() {
    if !accountDataManager.hasShownApplePayPopup {
      popupQueue.append(.applePay)
      accountDataManager.hasShownApplePayPopup = true
    }
  }
  
  private func checkShouldShowSpecialExperiencePopup() {
    Task {
      do {
        let response = try await shouldShowPopupUseCase.execute(campaign: "FRNT")
        
        if response.shouldShow {
          if popup == nil && popupQueue.isEmpty {
            popup = .specialExperience
            
            return
          }
          
          popupQueue.append(.specialExperience)
        }
      } catch {
        log.error(error)
      }
    }
  }
  
  func onSpecialExperiencePopupDismiss() {
    clearPopup()
    saveFrntShown()
    popupQueue.removeAll() { $0 == .specialExperience }
  }
  
  private func saveFrntShown() {
    Task {
      do {
        try await savePopupShownUseCaseProtocol.execute(campaign: "FRNT")
      } catch {
        log.error(error)
      }
    }
  }
  
  func presentNextPopupInQueue(
    removing: Popup?
  ) {
    guard popup == nil
    else {
      return
    }
    
    if let popupToRemove = removing {
      popupQueue.removeAll() { $0 == popupToRemove }
    }
    
    if let nextPopup = popupQueue.first {
      popup = nextPopup
    }
  }
  
  /// Presents the popup immediately if queue is empty or no popup is shown; otherwise adds it to the queue.
  func presentPopupOrEnqueue(_ popup: Popup) {
    if popupQueue.isEmpty && self.popup == nil {
      self.popup = popup
    } else {
      popupQueue.append(popup)
    }
  }
  
  func openTransactionId(_ id: String) {
    Task { @MainActor in
      navigation = .transactionDetail(id: id)
      pushNotificationService.clearSelection()
    }
  }
}

// MARK: Handle Interactions
extension MainTabBarModel {
  func onSelectedTab(tab: TabItem) {
    tabSelected = tab
  }
  
  func onSupportButtonTap() {
    customerSupportService.openSupportScreen()
  }
  
  func onApplePayButtonTap() {
    clearPopup()
    popupQueue.removeAll() { $0 == .applePay }
    navigation = .cardList
  }
  
  // Since this takes to the Assets tab, make sure this popup is the last in the queue
  func goToAssets() {
    clearPopup()
    tabSelected = .assets
  }
  
  func clearPopup() {
    popup = nil
  }
}

// MARK: - Handle APIs
extension MainTabBarModel {
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
        
        trackUserInformation(user: user)
      } catch {
        log.error(error.userFriendlyMessage)
      }
    }
  }
  
  func trackUserInformation(user: LFUser) {
    guard let userModel = user as? APIUser,
          let data = try? JSONEncoder().encode(userModel) else {
      return
    }
    
    let dictionary = (
      try? JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
    ).flatMap { $0 as? [String: Any] }
    
    var values = dictionary ?? [:]
    values["birthday"] = LiquidityDateFormatter.simpleDate.parseToDate(from: userModel.dateOfBirth ?? "")
    values["avatar"] = userModel.profileImage ?? ""
    values["idNumber"] = "REDACTED"
    
    analyticsService.set(params: values)
  }
  
  func fetchPending3DSChallenged() {
    guard featureFlagManager.isFeatureFlagEnabled(.pending3DSChallenge) else {
      return
    }
    
    Task {
      do {
        let pendingChallenges = try await rainGetPending3dsChallengesUseCase.execute()
          .map({ Pending3DSChallenge(entity: $0) })
        
        if let firstPendingChallenge = pendingChallenges.first,
           !popupQueue.contains(where: { $0 == .verifyTransaction(firstPendingChallenge)}) {
          presentPopupOrEnqueue(.verifyTransaction(firstPendingChallenge))
        }
      } catch {
        log.error("Get Pendding 3DS Challenge Error: \(error.localizedDescription)")
      }
    }
  }
}

// MARK: Notifications
extension MainTabBarModel {
  func checkGoTransactionDetail() {
    guard let event = pushNotificationService.event else {
      return
    }
    switch event {
    case let .transaction(id):
      openTransactionId(id)
    default:
      break
    }
  }

  // Observe the notification event from the push notification service
  // including tapping the notification or the notification is received in the foreground
  func notificationObserver() {
    pushNotificationService.eventPublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak self] event in
        guard let self,
              let event
        else { return }
        
        switch event {
        case let .pending3DSChallenge(id, currency, amount, merchantCountry, merchantName):
          if self.featureFlagManager.isFeatureFlagEnabled(.pending3DSChallenge) {
            let pendingChallenge = Pending3DSChallenge(
              id: id,
              currency: currency,
              amount: amount,
              merchantCountry: merchantCountry,
              merchantName: merchantName
            )
            self.presentPopupOrEnqueue(.verifyTransaction(pendingChallenge))
          }
          
        default:
          break
        }
      }
      .store(in: &subscribers)
  }
  
  func checkShouldShowNotification() {
    Task { @MainActor in
      do {
        let status = try await pushNotificationService.notificationSettingStatus()
        let shouldPresentNotificationPopup = !UserDefaults.didShowPushTokenPopup && status == .notDetermined
        
        presentNextPopupInQueue(removing: shouldPresentNotificationPopup ? nil : .notifications)
        UserDefaults.didShowPushTokenPopup = true
        
        if status == .authorized && UserDefaults.enabledNotificationSetting {
          self.pushFCMTokenIfNeed()
        }
      } catch {
        log.error(error)
      }
    }
  }
  
  func pushFCMTokenIfNeed() {
    guard hadPushToken == false else { return }
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
  
  func notificationsPopupAction() {
    clearPopup()
    
    Task { @MainActor in
      do {
        let success = try await pushNotificationService.requestPermission()
        if success {
          UserDefaults.enabledNotificationSetting = true
          self.accountViewModel.notificationsEnabled = true
          self.pushFCMTokenIfNeed()
        }
        
        presentNextPopupInQueue(removing: .notifications)
      } catch {
        log.error(error)
      }
    }
  }
}

// MARK: - Enums
extension MainTabBarModel {
  enum Navigation {
    case transactionDetail(id: String)
    case cardList
  }
  
  enum Popup: Identifiable, Equatable {
    case notifications
    case specialExperience
    case applePay
    case verifyTransaction(Pending3DSChallenge)
    
    var id: String {
      switch self {
      case .verifyTransaction(let transaction):
        return "verifyTransaction-\(transaction.id)"
      default:
        return String(describing: self)
      }
    }
    
    static func == (lhs: MainTabBarModel.Popup, rhs: MainTabBarModel.Popup) -> Bool {
      lhs.id == rhs.id
    }
  }
}
