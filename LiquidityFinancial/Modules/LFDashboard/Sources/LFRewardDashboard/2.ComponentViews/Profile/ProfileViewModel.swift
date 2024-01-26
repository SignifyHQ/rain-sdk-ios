import Foundation
import UIKit
import Factory
import LFUtilities
import AuthorizationManager
import RewardData
import RewardDomain
import Services
import Combine
import DevicesDomain
import LFFeatureFlags

@MainActor
final class ProfileViewModel: ObservableObject {
  @Published var isLoadingContribution: Bool = false
  @Published var showContributionToast: Bool = false
  @Published var isLoading: Bool = false
  @Published var contribution: Contribution?
  @Published var navigation: Navigation?
  @Published var popup: Popup?
  @Published var notificationsEnabled = false
  
  @LazyInjected(\.customerSupportService) var customerSupportService
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.authorizationManager) var authorizationManager
  @LazyInjected(\.rewardDataManager) var rewardDataManager
  @LazyInjected(\.rewardRepository) var rewardRepository
  @LazyInjected(\.pushNotificationService) var pushNotificationService
  @LazyInjected(\.analyticsService) var analyticsService
  @LazyInjected(\.devicesRepository) var devicesRepository
  @LazyInjected(\.featureFlagManager) var featureFlagManager
  
  private var cancellable = Set<AnyCancellable>()
  
  lazy var rewardUseCase: RewardUseCase = {
    RewardUseCase(repository: rewardRepository)
  }()
  
  lazy var deviceDeregisterUseCase: DeviceDeregisterUseCaseProtocol = {
    DeviceDeregisterUseCase(repository: devicesRepository)
  }()
  
  lazy var deviceRegisterUseCase: DeviceRegisterUseCaseProtocol = {
    DeviceRegisterUseCase(repository: devicesRepository)
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
    Double(contribution?.donationAmount ?? 0).formattedUSDAmount()
  }
  
  var stickers: [Sticker] {
    contribution?.stickers ?? []
  }
  
  var isPasswordLoginEnabled: Bool {
    featureFlagManager.isFeatureFlagEnabled(.passwordLogin)
  }
  
  var phoneNumber: String {
    let phoneNumber = accountDataManager.userInfomationData.phone ?? accountDataManager.phoneNumber
    return phoneNumber.formattedUSPhoneNumber()
  }
  
  var address: String {
    accountDataManager.addressDetail
  }
  
  var showStickers: Bool {
    isLoadingContribution || !stickers.isEmpty
  }
  
  var isShowWarningSecurityIcon: Bool {
    let isMFAEnabled = accountDataManager.userInfomationData.mfaEnabled ?? false
    let isEmailVerified = accountDataManager.userInfomationData.emailVerified ?? false
    
    return !(isMFAEnabled && isEmailVerified && accountDataManager.isBiometricUsageEnabled)
  }
  
  init() {
    checkNotificationsStatus()
    handleForceLogoutInErrorView()
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
    popup = .noticeOfDeletion
  }
  
  func deleteAccount() {
    analyticsService.track(event: AnalyticsEvent(name: .deleteAccount))
    logout()
  }
  
  func dismissPopup() {
    popup = nil
  }
}

extension ProfileViewModel {
  func checkNotificationsStatus() {
    checkNotificationsStatus { @MainActor [weak self] status in
      self?.notificationsEnabled = status
    }
  }
}

// MARK: Notification
extension ProfileViewModel {
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

extension ProfileViewModel {
  private func loadContribution() async {
    do {
      defer { isLoadingContribution = false }
      isLoadingContribution = true
      let entity = try await rewardUseCase.getUserDonationSummary()
      self.contribution = Contribution(entity: entity)
    } catch {
      log.error(error.userFriendlyMessage)
    }
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

// MARK: - Types
extension ProfileViewModel {
  enum Navigation {
    case depositLimits
    case referrals
    case securityHub
  }
  
  enum Popup {
    case noticeOfDeletion
    case deleteAccount
    case logout
  }
}
