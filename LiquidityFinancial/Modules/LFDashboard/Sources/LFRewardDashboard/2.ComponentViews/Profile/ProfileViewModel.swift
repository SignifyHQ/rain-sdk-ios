import Foundation
import Factory
import LFUtilities
import AuthorizationManager
import RewardData
import RewardDomain

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
  @LazyInjected(\.rewardDataManager) var rewardDataManager
  @LazyInjected(\.rewardRepository) var rewardRepository

  lazy var rewardUseCase: RewardUseCase = {
    RewardUseCase(repository: rewardRepository)
  }()
  
  var name: String {
    accountDataManager.userInfomationData.fullName ?? ""
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
    Double(contribution?.donationAmount ?? 0).formattedAmount(prefix: Constants.CurrencyUnit.usd.rawValue)
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
    do {
      defer { isLoadingContribution = false }
      isLoadingContribution = true
      let entity = try await rewardUseCase.getUserDonationSummary()
      self.contribution = Contribution(entity: entity)
    } catch {
      log.error(error.localizedDescription)
    }
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
