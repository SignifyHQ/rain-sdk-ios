import UIKit
import Foundation
import Factory
import OnboardingData
import AccountData
import LFUtilities
import DevicesData

@MainActor
public final class HomeViewModel: ObservableObject {
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.pushNotificationService) var pushNotificationService
  @LazyInjected(\.devicesRepository) var devicesRepository
  
  @Published var isShowGearButton: Bool = false
  @Published var tabSelected: TabOption = .cash
  @Published var navigation: Navigation?
  @Published var popup: Popup?
  
  public init() {
    getUser()
  }
}

// MARK: - API
extension HomeViewModel {
  private func getUser() {
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

// MARK: Notifications
extension HomeViewModel {
  
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
    case searchCauses
    case editRewards
    case profile
  }
  
  enum Popup {
    case notifications
  }
}
