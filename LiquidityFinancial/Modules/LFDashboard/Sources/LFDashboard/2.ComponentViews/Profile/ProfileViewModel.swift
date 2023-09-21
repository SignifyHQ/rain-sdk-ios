import Foundation
import UIKit
import Factory
import LFUtilities
import AuthorizationManager
import LFServices

@MainActor
final class ProfileViewModel: ObservableObject {
  @Published var isLoadingContribution: Bool = false
  @Published var showContributionToast: Bool = false
  @Published var isLoading: Bool = false
  @Published var contribution: Contribution?
  @Published var navigation: Navigation?
  @Published var popup: Popup?
  @Published var notificationsEnabled = false
  
  @LazyInjected(\.intercomService) var intercomService
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.authorizationManager) var authorizationManager
  @LazyInjected(\.devicesRepository) var devicesRepository
  @LazyInjected(\.pushNotificationService) var pushNotificationService
  @LazyInjected(\.analyticsService) var analyticsService
  
  var name: String {
    if let firstName = accountDataManager.userInfomationData.firstName,
       let lastName = accountDataManager.userInfomationData.lastName {
      return firstName + " " + lastName
    }
    return accountDataManager.userInfomationData.fullName ?? ""
  }

  var email: String {
    accountDataManager.userInfomationData.email ?? ""
  }

  var totalDonations: String {
    guard let totalDonations = contribution?.totalDonations else {
      return Constants.Default.undefinedSymbol.rawValue
    }
    return String(totalDonations)
  }

  var totalDonated: String {
    contribution?.totalAmount.formattedAmount(prefix: Constants.CurrencyUnit.usd.rawValue) ?? Constants.Default.undefinedSymbol.rawValue
  }

  var stickers: [Sticker] {
    contribution?.stickers ?? []
  }

  var phoneNumber: String {
    let phoneNumber = accountDataManager.userInfomationData.phone ?? accountDataManager.phoneNumber
    return phoneNumber.formattedUSPhoneNumber()
  }

  var address: String {
    accountDataManager.addressDetail
  }
  
  var showContribution: Bool {
    LFUtility.charityEnabled
  }

  var showStickers: Bool {
    guard LFUtility.charityEnabled else {
      return false
    }
    return isLoadingContribution || !stickers.isEmpty
  }
  
  init() {
    checkNotificationsStatus()
  }
}

// MARK: - Actions
extension ProfileViewModel {
  func onAppear() {
    Task {
      await loadContribution()
    }
  }
  
  func showReferrals() {
    navigation = .referrals
  }
  
  func depositLimitsTapped() {
    navigation = .depositLimits
  }
  
  func helpTapped() {
    intercomService.openIntercom()
  }
  
  func logoutTapped() {
    popup = .logout
  }
  
  func logout() {
    analyticsService.track(event: AnalyticsEvent(name: .loggedOut))
    Task {
      defer {
        isLoading = false
        authorizationManager.clearToken()
        accountDataManager.clearUserSession()
        authorizationManager.forcedLogout()
        intercomService.pushEventLogout()
        dismissPopup()
        pushNotificationService.signOut()
      }
      isLoading = true
      do {
        async let deregisterEntity = devicesRepository.deregister(deviceId: LFUtility.deviceId, token: UserDefaults.lastestFCMToken)
        async let logoutEntity = accountRepository.logout()
        let deregister = try await deregisterEntity
        let logout = try await logoutEntity
        log.debug(deregister)
        log.debug(logout)
      } catch {
        log.error(error.localizedDescription)
      }
    }
  }
  
  func deleteAccountTapped() {
    popup = .deleteAccount
  }
  
  func deleteAccount() {
    analyticsService.track(event: AnalyticsEvent(name: .deleteAccount))
    logout()
    authorizationManager.clearToken()
    accountDataManager.clearUserSession()
    authorizationManager.forcedLogout()
    intercomService.pushEventLogout()
    dismissPopup()
    pushNotificationService.signOut()
  }
  
  func dismissPopup() {
    popup = nil
  }
}

extension ProfileViewModel {
  func checkNotificationsStatus() {
    Task { @MainActor in
      do {
        let status = try await pushNotificationService.notificationSettingStatus()
        self.notificationsEnabled = status == .authorized
      } catch {
        log.error(error.localizedDescription)
      }
    }
  }
  
  func notificationTapped() {
    Task { @MainActor in
      do {
        let status = try await pushNotificationService.notificationSettingStatus()
        switch status {
        case .authorized:
          break
        case .notDetermined:
          let success = try await pushNotificationService.requestPermission()
          if success {
            break
          }
          return
        case .denied:
          if let settingsUrl = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(settingsUrl) {
            await UIApplication.shared.open(settingsUrl)
          }
          return
        default:
          return
        }
        self.pushFCMTokenIfNeed()
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
}

extension ProfileViewModel {
  private func loadContribution() async {
    // TODO: Will be implemented later
  }
}

// MARK: - Types
extension ProfileViewModel {
  enum Navigation {
    case depositLimits
    case referrals
  }
  
  enum Popup {
    case deleteAccount
    case logout
  }
}
