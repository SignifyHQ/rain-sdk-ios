import Foundation
import Factory
import LFUtilities
import AuthorizationManager

@MainActor
final class ProfileViewModel: ObservableObject {
  @Published var isNotificationsEnabled: Bool = false
  @Published var isLoadingContribution: Bool = false
  @Published var showContributionToast: Bool = false
  @Published var isLoading: Bool = false
  @Published var contribution: Contribution?
  @Published var navigation: Navigation?
  @Published var popup: Popup?
  
  @LazyInjected(\.intercomService) var intercomService
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.authorizationManager) var authorizationManager
  @LazyInjected(\.devicesRepository) var devicesRepository

  var name: String {
    accountDataManager.userInfomationData.fullName ?? ""
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
  
  func notificationsTapped() {
    requestNotificationPermission()
  }
  
  func logoutTapped() {
    popup = .logout
  }
  
  func logout() {
    Task {
      defer {
        isLoading = false
        authorizationManager.clearToken()
        accountDataManager.clearUserSession()
        authorizationManager.forcedLogout()
        intercomService.pushEventLogout()
        dismissPopup()
      }
      isLoading = true
      do {
        _ = try await devicesRepository.deregister(deviceId: LFUtility.deviceId, token: UserDefaults.lastestFCMToken)
        _ = try await accountRepository.logout()
      } catch {
        log.error(error.localizedDescription)
      }
    }
  }
  
  func deleteAccountTapped() {
    popup = .deleteAccount
  }
  
  func deleteAccount() {
    logout()
    authorizationManager.clearToken()
    accountDataManager.clearUserSession()
    authorizationManager.forcedLogout()
    intercomService.pushEventLogout()
    dismissPopup()
  }
  
  func dismissPopup() {
    popup = nil
  }
}

extension ProfileViewModel {
  private func loadContribution() async {
    // TODO: Will be implemented later
  }
  
  func checkNotificationsStatus() {
    // TODO: Will be implemented later
  }
  
  private func requestNotificationPermission() {
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
