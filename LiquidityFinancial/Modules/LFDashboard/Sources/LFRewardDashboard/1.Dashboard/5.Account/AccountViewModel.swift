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
  @LazyInjected(\.nsPersonRepository) var nsPersonRepository
  @LazyInjected(\.externalFundingRepository) var externalFundingRepository
  @LazyInjected(\.netspendDataManager) var netspendDataManager
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
  
  lazy var getAuthorizationUseCase: NSGetAuthorizationCodeUseCaseProtocol = {
    NSGetAuthorizationCodeUseCase(repository: nsPersonRepository)
  }()
  
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
  
  func getLastFourDigits(from value: String) -> String {
    let showCount = 4
    let lastIndex = value.count

    return lastIndex >= showCount ? value.substring(start: lastIndex - showCount, end: lastIndex) : value
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
  
  func getATMAuthorizationCode() {
    Task {
      defer {
        isLoading = false
        isDisableView = false
      }
      isLoading = true
      isDisableView = true
      do {
        let sessionID = accountDataManager.sessionID
        let code = try await getAuthorizationUseCase.execute(sessionId: sessionID)
        navigation = .atmLocation(code.authorizationCode)
      } catch {
        toastMessage = error.localizedDescription
      }
    }
  }
  
  func getDisputeAuthorizationCode() {
    Task {
      defer {
        isLoadingDisputeTransaction = false
        isDisableView = false
      }
      isLoadingDisputeTransaction = true
      isDisableView = true
      do {
        guard let session = netspendDataManager.sdkSession else { return }
        let code = try await getAuthorizationUseCase.execute(sessionId: session.sessionId)
        guard let id = accountDataManager.externalAccountID else { return }
        navigation = .disputeTransaction(id, code.authorizationCode)
      } catch {
        toastMessage = error.localizedDescription
      }
    }
  }
  
  func subscribeLinkedContacts() {
    externalFundingDataManager.subscribeLinkedSourcesChanged({ [weak self] contacts in
      self?.linkedContacts = contacts
    })
    .store(in: &cancellable)
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
