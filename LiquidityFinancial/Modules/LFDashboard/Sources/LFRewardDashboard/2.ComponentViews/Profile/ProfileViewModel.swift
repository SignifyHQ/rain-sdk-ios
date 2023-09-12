import Foundation
import UIKit
import Factory
import LFUtilities
import AuthorizationManager
import RewardData
import RewardDomain

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
  @LazyInjected(\.rewardDataManager) var rewardDataManager
  @LazyInjected(\.rewardRepository) var rewardRepository
  @LazyInjected(\.pushNotificationService) var pushNotificationService
  @LazyInjected(\.devicesRepository) var devicesRepository

  lazy var rewardUseCase: RewardUseCase = {
    RewardUseCase(repository: rewardRepository)
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

  var totalDonations: String {
    guard let totalDonations = contribution?.donationCount else {
      return Constants.Default.undefinedSymbol.rawValue
    }
    return String(totalDonations)
  }

  var totalDonated: String {
    Double(contribution?.donationAmount ?? 0)
      .formattedAmount(prefix: Constants.CurrencyUnit.usd.rawValue)
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
    isLoadingContribution || !stickers.isEmpty
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
    do {
      defer { isLoadingContribution = false }
      isLoadingContribution = true
      let entity = try await rewardUseCase.getUserDonationSummary()
      self.contribution = Contribution(entity: entity)
    } catch {
      log.error(error.localizedDescription)
    }
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
