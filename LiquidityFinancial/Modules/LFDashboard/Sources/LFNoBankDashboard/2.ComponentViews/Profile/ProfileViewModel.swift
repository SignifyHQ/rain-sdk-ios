import Foundation
import UIKit
import Factory
import LFUtilities
import AuthorizationManager
import Services
import DevicesDomain
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
  @Published var isLoading: Bool = false
  @Published var navigation: Navigation?
  @Published var popup: Popup?
  @Published var notificationsEnabled = false
  
  @LazyInjected(\.customerSupportService) var customerSupportService
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.authorizationManager) var authorizationManager
  @LazyInjected(\.devicesRepository) var devicesRepository
  @LazyInjected(\.pushNotificationService) var pushNotificationService
  @LazyInjected(\.analyticsService) var analyticsService
  
  lazy var deviceDeregisterUseCase: DeviceDeregisterUseCaseProtocol = {
    DeviceDeregisterUseCase(repository: devicesRepository)
  }()
  lazy var deviceRegisterUseCase: DeviceRegisterUseCaseProtocol = {
    DeviceRegisterUseCase(repository: devicesRepository)
  }()
  
  private var cancellable = Set<AnyCancellable>()
  
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

  var phoneNumber: String {
    let phoneNumber = accountDataManager.userInfomationData.phone ?? accountDataManager.phoneNumber
    return phoneNumber.formattedUSPhoneNumber()
  }

  var address: String {
    accountDataManager.addressDetail
  }
  
  init() {
    checkNotificationsStatus()
    handleForceLogoutInErrorView()
  }
}

// MARK: - Actions
extension ProfileViewModel {
  func onAppear() {

  }
  
  func showReferrals() {
    navigation = .referrals
  }
  
  func depositLimitsTapped() {
    navigation = .depositLimits
  }
  
  func helpTapped() {
    customerSupportService.openSupportScreen()
  }
  
  func logoutTapped() {
    popup = .logout
  }
  
  func didTapSecurityButton() {
    navigation = .securityHub
  }
  
  func logout(animated: Bool = true) {
    analyticsService.track(event: AnalyticsEvent(name: .loggedOut))
    Task {
      do {
        if animated {
          defer {
            isLoading = false
          }
          isLoading = true
        }
        async let deregisterEntity = deviceDeregisterUseCase.execute(deviceId: LFUtilities.deviceId, token: UserDefaults.lastestFCMToken)
        async let logoutEntity = accountRepository.logout()
        let deregister = try await deregisterEntity
        let logout = try await logoutEntity
        
        authorizationManager.clearToken()
        accountDataManager.clearUserSession()
        authorizationManager.forcedLogout()
        customerSupportService.pushEventLogout()
        dismissPopup()
        pushNotificationService.signOut()
        
        log.debug(deregister)
        log.debug(logout)
      } catch {
        log.error(error.userFriendlyMessage)
      }
    }
  }
  
  func deleteAccountTapped() {
    popup = .deleteAccount
  }
  
  func deleteAccount() {
    analyticsService.track(event: AnalyticsEvent(name: .deleteAccount))
    logout()
  }
  
  func dismissPopup() {
    popup = nil
  }
  
  private func handleForceLogoutInErrorView() {
    NotificationCenter.default.publisher(for: .forceLogoutInAnyWhere)
      .sink { [weak self] _ in
        guard let self else { return }
        self.logout(animated: false)
      }
      .store(in: &cancellable)
  }
}

// MARK: Notification
extension ProfileViewModel {
  func checkNotificationsStatus() {
    checkNotificationsStatus { @MainActor [weak self] status in
      self?.notificationsEnabled = status
    }
  }
  
  private func checkNotificationsStatus(completion: @escaping (Bool) -> Void) {
    Task { @MainActor in
      do {
        let status = try await pushNotificationService.notificationSettingStatus()
        completion(status == .authorized)
      } catch {
        completion(false)
        log.error(error.userFriendlyMessage)
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
        let response = try await deviceRegisterUseCase.execute(deviceId: LFUtilities.deviceId, token: token)
        if response.success {
          UserDefaults.lastestFCMToken = token
        }
      } catch {
        log.error(error.userFriendlyMessage)
      }
    }
  }

}

// MARK: - Types
extension ProfileViewModel {
  enum Navigation {
    case depositLimits
    case referrals
    case securityHub
  }
  
  enum Popup {
    case deleteAccount
    case logout
  }
}
