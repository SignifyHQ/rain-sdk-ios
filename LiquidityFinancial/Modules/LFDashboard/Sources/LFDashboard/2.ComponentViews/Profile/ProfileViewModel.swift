import Foundation
import UIKit
import Factory
import LFUtilities
import AuthorizationManager
import Services
import DevicesDomain

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
  @LazyInjected(\.dashboardRepository) var dashboardRepository
  
  lazy var deviceDeregisterUseCase: DeviceDeregisterUseCaseProtocol = {
    return DeviceDeregisterUseCase(repository: devicesRepository)
  }()
  
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
  
  func logout() {
    analyticsService.track(event: AnalyticsEvent(name: .loggedOut))
    Task {
      defer {
        isLoading = false
        authorizationManager.clearToken()
        accountDataManager.clearUserSession()
        authorizationManager.forcedLogout()
        customerSupportService.pushEventLogout()
        dismissPopup()
        pushNotificationService.signOut()
      }
      isLoading = true
      do {
        async let deregisterEntity = deviceDeregisterUseCase.execute(deviceId: LFUtilities.deviceId, token: UserDefaults.lastestFCMToken)
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
    customerSupportService.pushEventLogout()
    dismissPopup()
    pushNotificationService.signOut()
  }
  
  func dismissPopup() {
    popup = nil
  }
}

extension ProfileViewModel {
  func checkNotificationsStatus() {
    dashboardRepository.checkNotificationsStatus { @MainActor [weak self] status in
      self?.notificationsEnabled = status
    }
  }
  
  func notificationTapped() {
    dashboardRepository.notificationTapped()
  }
  
  func pushFCMTokenIfNeed() {
    dashboardRepository.pushFCMTokenIfNeed()
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
