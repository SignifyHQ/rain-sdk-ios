import UIKit
import Foundation
import Factory
import AccountData
import LFUtilities
import DevicesData
import AccountDomain
import Combine
import LFNetspendBank
import Services
import DevicesDomain

@MainActor
final class HomeViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.devicesRepository) var devicesRepository
  
  @LazyInjected(\.pushNotificationService) var pushNotificationService
  
  @LazyInjected(\.customerSupportService) var customerSupportService
  
  @Published var isShowGearButton: Bool = false
  @Published var tabSelected: TabOption = .cash
  @Published var tabOptions: [TabOption] = [.cash, .rewards, .account]
  @Published var navigation: Navigation?
  @Published var popup: Popup?
  
  @Published var toastMessage: String?

  private var hadPushToken: Bool = false
  
  lazy var deviceRegisterUseCase: DeviceRegisterUseCaseProtocol = {
    DeviceRegisterUseCase(repository: devicesRepository)
   }()
  
  let dashboardRepository: DashboardRepository
  init(dashboardRepository: DashboardRepository, tabOptions: [TabOption]) {
    self.dashboardRepository = dashboardRepository
    self.tabOptions = tabOptions
    
    initData()
    accountDataManager.userCompleteOnboarding = true
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

}

// MARK: API init data tab content
extension HomeViewModel {
  
  func initData() {
    apiFetchUser()
  }
  
  func onAppear() {
    checkShouldShowNotification()
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
}

// MARK: Notifications
extension HomeViewModel {
  
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
      } catch {
        log.error(error)
      }
    }
  }

  func clearPopup() {
    popup = nil
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
  }
  
  enum Popup {
    case notifications
  }
}
