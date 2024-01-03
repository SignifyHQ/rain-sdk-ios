import Combine
import UIKit
import LFUtilities
import Factory
import AccountDomain
import AccountData
import EnvironmentService
import DashboardComponents

@MainActor
class AccountViewModel: ObservableObject {
  enum OpenSafariType: Identifiable {
    var id: String {
      switch self {
      case .legal(let url):
        return url.absoluteString
      }
    }
    
    case legal(URL)
  }
  
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.customerSupportService) var customerSupportService
  @LazyInjected(\.pushNotificationService) var pushNotificationService
  @LazyInjected(\.environmentService) var environmentService
  
  @Published var navigation: Navigation?
  
  @Published var notificationsEnabled = false
  @Published var sheet: Sheet?
  @Published var isLoadingAssets: Bool = false
  
  @Published var toastMessage: String?
  @Published var assets: [AssetModel] = []
  
  private var cancellable: Set<AnyCancellable> = []
  
  var networkEnvironment: NetworkEnvironment {
    environmentService.networkEnvironment
  }
  
  var showAdminMenu: Bool {
    if let userData = accountDataManager.userInfomationData as? UserInfomationData {
      return userData.accessLevel == UserInfomationData.AccessLevel.INTERNAL
    }
    return false
  }
  
  let dashboardRepository: DashboardRepository
  init(dashboardRepo: DashboardRepository) {
    dashboardRepository = dashboardRepo
    subscribeCryptoAccount()
    
    checkNotificationsStatus()
  }
  
  func subscribeCryptoAccount() {
    dashboardRepository
      .$cryptoData
      .receive(on: DispatchQueue.main)
      .sink { [weak self] cryptoData in
        if cryptoData.loading {
          let assets = cryptoData.cryptoAccounts.compactMap({
            AssetModel(
              id: $0.id,
              type: AssetType(rawValue: $0.currency.rawValue.uppercased()),
              availableBalance: $0.availableBalance,
              availableUsdBalance: $0.availableUsdBalance,
              externalAccountId: $0.externalAccountId
            )
          })
          self?.assets = assets
        }
      }
      .store(in: &cancellable)
  }
  
}

  // MARK: - View Helpers
extension AccountViewModel {
  func getLastFourDigits(from value: String) -> String {
    let showCount = 4
    let lastIndex = value.count
    
    return lastIndex >= showCount ? value.substring(start: lastIndex - showCount, end: lastIndex) : value
  }
  
  func selectedAddOption(navigation: Navigation) {
    self.navigation = navigation
  }
  
  func opencustomerSupportService() {
    customerSupportService.openSupportScreen()
  }
  
  func openTaxes() {
    navigation = .taxes
  }
  
  func openLegal() {
    sheet = .legal
  }
  
  func openWalletAddress(asset: AssetModel) {
    navigation = .wallet(asset: asset)
  }
  
  func openReward() {
    navigation = .rewards
  }
  
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
  
  func getUrl() -> URL? {
    URL(string: LFUtilities.termsURL)
  }
  
  func helpTapped() {
    customerSupportService.openSupportScreen()
  }
}

  // MARK: - Types
extension AccountViewModel {
  enum Navigation {
    case debugMenu
    case taxes
    case wallet(asset: AssetModel)
    case rewards
  }
  
  enum Sheet: Hashable, Identifiable {
    static func == (lhs: AccountViewModel.Sheet, rhs: AccountViewModel.Sheet) -> Bool {
      return lhs.hashRawValue == rhs.hashRawValue
    }
    func hash(into hasher: inout Hasher) {
      hasher.combine(hashRawValue)
    }
    var hashRawValue: Int {
      switch self {
      case .legal: return 0
      }
    }
    var id: Self {
      self
    }
    case legal
  }
}
