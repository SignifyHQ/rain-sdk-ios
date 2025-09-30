import UIKit
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
final class HomeViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.biometricsManager) var biometricsManager

  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.devicesRepository) var devicesRepository
  @LazyInjected(\.rainRepository) var rainRepository

  @LazyInjected(\.pushNotificationService) var pushNotificationService
  
  @LazyInjected(\.analyticsService) var analyticsService
  @LazyInjected(\.customerSupportService) var customerSupportService
  
  @Published var isShowGearButton: Bool = false
  @Published var shouldShowBiometricsFallback: Bool = false
  @Published var tabSelected: TabOption = .cash
  @Published var tabOptions: [TabOption] = []
  @Published var navigation: Navigation?
  
  @Published var popup: Popup?
  private var popupQueue: [Popup] = [.notifications]
  
  @Published var isLoading: Bool = false
  @Published var toastMessage: String?

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
  
  let dashboardRepository: DashboardRepository
  init(dashboardRepository: DashboardRepository, tabOptions: [TabOption]) {
    self.dashboardRepository = dashboardRepository
    self.tabOptions = tabOptions
    
    self.dashboardRepository.toastMessage = { [weak self] message in
      guard let self else { return }
      self.toastMessage = message
    }
    
    initData()
    accountDataManager.userCompleteOnboarding = true
    checkGoTransactionDetail()
    UserDefaults.isStartedWithLoginFlow = false
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
}

// MARK: API init data tab content
extension HomeViewModel {
  
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
    logincustomerSupportService()
    dashboardRepository.onAppear()
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
}

// MARK: Notifications
extension HomeViewModel {
  func checkGoTransactionDetail() {
    guard let event = pushNotificationService.event else {
      return
    }
    switch event {
    case let .transaction(id):
      openTransactionId(id)
    }
  }
  
  func checkShouldShowNotification() {
    Task { @MainActor in
      do {
        let status = try await pushNotificationService.notificationSettingStatus()
        let shouldPresentNotificationPopup = !UserDefaults.didShowPushTokenPopup && status == .notDetermined
        
        presentNextPopupInQueue(removing: shouldPresentNotificationPopup ? nil : .notifications)
        UserDefaults.didShowPushTokenPopup = true
        
        if status == .authorized {
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
          self.pushFCMTokenIfNeed()
        }
        
        presentNextPopupInQueue(removing: .notifications)
      } catch {
        log.error(error)
      }
    }
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
  
  func openTransactionId(_ id: String) {
    Task { @MainActor in
      navigation = .transactionDetail(id: id)
      pushNotificationService.clearSelection()
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
    case transactionDetail(id: String)
    case cardList
  }
  
  enum Popup {
    case notifications
    case specialExperience
    case applePay
  }
}
