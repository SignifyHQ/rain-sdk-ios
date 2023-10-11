import Combine
import Foundation
import UIKit
import LFUtilities
import Factory
import NetSpendData
import NetSpendDomain
import NetspendSdk
import LFBaseBank
import LFBank
import AccountData

@MainActor
class AccountViewModel: ObservableObject {
  @LazyInjected(\.nsPersionRepository) var nsPersionRepository
  @LazyInjected(\.externalFundingRepository) var externalFundingRepository
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.customSupportService) var customSupportService
  @LazyInjected(\.pushNotificationService) var pushNotificationService
  @LazyInjected(\.dashboardRepository) var dashboardRepository
  
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
  
  private(set) var addFundsViewModel = AddFundsViewModel()
  
  private var cancellable: Set<AnyCancellable> = []
  
  var networkEnvironment: NetworkEnvironment {
    EnvironmentManager().networkEnvironment
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
    
    subscribeLinkedAccounts()
    handleFundingAgreementData()
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
  
  func opencustomSupportService() {
    customSupportService.openSupportScreen()
  }
  
  func handleFundingAgreementData() {
    addFundsViewModel.fundingAgreementData
      .receive(on: DispatchQueue.main)
      .sink { [weak self] agreementData in
        self?.openFundingAgreement(data: agreementData)
      }
      .store(in: &cancellable)
  }
  
  func handleFundingAcceptAgreement(isAccept: Bool) {
    if isAccept {
      addFundsViewModel.goNextNavigation()
    } else {
      addFundsViewModel.stopAction()
    }
  }
  
  func openFundingAgreement(data: APIAgreementData?) {
    if data == nil {
      navigation = nil
    } else {
      navigation = .agreement(data)
    }
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
        let code = try await nsPersionRepository.getAuthorizationCode(sessionId: sessionID)
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
        let code = try await nsPersionRepository.getAuthorizationCode(sessionId: session.sessionId)
        guard let id = accountDataManager.externalAccountID else { return }
        navigation = .disputeTransaction(id, code.authorizationCode)
      } catch {
        toastMessage = error.localizedDescription
      }
    }
  }
  
  func subscribeLinkedAccounts() {
    accountDataManager.subscribeLinkedSourcesChanged { [weak self] entities in
      guard let self = self else { return }
      let linkedSources = entities.compactMap({ APILinkedSourceData(entity: $0) })
      self.linkedAccount = linkedSources
    }
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
    case agreement(APIAgreementData?)
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
