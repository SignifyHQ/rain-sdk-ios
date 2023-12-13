import Combine
import ExternalFundingData
import Foundation
import UIKit
import LFUtilities
import Factory
import NetSpendData
import NetspendDomain
import NetspendSdk
import LFBaseBank
import LFSolidBank
import AccountData
import EnvironmentService

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
  
  @LazyInjected(\.externalFundingRepository) var externalFundingRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.customerSupportService) var customerSupportService
  @LazyInjected(\.pushNotificationService) var pushNotificationService
  @LazyInjected(\.dashboardRepository) var dashboardRepository
  @LazyInjected(\.externalFundingDataManager) var externalFundingDataManager
  @LazyInjected(\.environmentService) var environmentService
  
  @Published var navigation: Navigation?
  @Published var isDisableView: Bool = false
  @Published var isLoadingACH: Bool = false
  @Published var isLoadingDisputeTransaction: Bool = false
  @Published var isLoading: Bool = false
  @Published var openLegal = false
  @Published var notificationsEnabled = false
  @Published var toastMessage: String?
  @Published var linkedAccount: [APILinkedSourceData] = []
  @Published var achInformation: ACHModel = .default
  @Published var sheet: Sheet?
  @Published var linkedContacts: [LinkedSourceContact] = []
  
  private(set) var addFundsViewModel = AddFundsViewModel()
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
  
  init(achInformationData: Published<(model: ACHModel, loading: Bool)>.Publisher) {
    achInformationData
      .receive(on: DispatchQueue.main)
      .sink { [weak self] achModel in
        self?.isLoadingACH = achModel.loading
        self?.achInformation = achModel.model
      }
      .store(in: &cancellable)
    
    subscribeLinkedContacts()
    checkNotificationsStatus()
  }
}

// MARK: - View Helpers
extension AccountViewModel {
  func selectedAddOption(navigation: Navigation) {
    self.navigation = navigation
  }
  
  func connectedAccountsTapped() {
    navigation = .connectedAccounts
  }
  
  func onClickedDepositLimitsButton() {
    navigation = .depositLimits
  }
  
  func bankStatementTapped() {
    navigation = .bankStatement
  }
  
  func opencustomerSupportService() {
    customerSupportService.openSupportScreen()
  }
  
  func openReward() {
    navigation = .rewards
  }
}

// MARK: - API
extension AccountViewModel {
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
  
  func subscribeLinkedContacts() {
    externalFundingDataManager.subscribeLinkedSourcesChanged({ [weak self] contacts in
      self?.linkedContacts = contacts.filter { $0.sourceType == .bank}
    })
    .store(in: &cancellable)
  }
  
  func getUrl() -> URL? {
    URL(string: LFUtilities.termsURL)
  }
}

// MARK: - Types
extension AccountViewModel {
  enum Navigation {
    case debugMenu
    case atmLocation(String)
    case depositLimits
    case connectedAccounts
    case bankStatement
    case disputeTransaction(String, String)
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
