import Combine
import Foundation
import UIKit
import LFUtilities
import Factory
import NetSpendData
import NetspendDomain
import NetspendSdk
import LFNetspendBank
import LFBaseBank
import BaseDashboard
import AccountDomain
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
  @LazyInjected(\.environmentService) var environmentService
  
  @Published var navigation: Navigation?
  
  @Published var isDisableView: Bool = false
  @Published var isLoadingACH: Bool = false
  @Published var isLoadingDisputeTransaction: Bool = false
  @Published var isLoadingAuthorization: Bool = false
  @Published var notificationsEnabled = false
  @Published var sheet: Sheet?
  @Published var isLoadingAssets: Bool = false
  
  @Published var netspendController: NetspendSdkViewController?
  @Published var toastMessage: String?
  @Published var linkedAccount: [APILinkedSourceData] = []
  @Published var achInformation: ACHModel = .default
  @Published var assets: [AssetModel] = []
  
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
  
  init() {
    subscribeCryptoAccount()
    
    subscribeACHInformation()
    
    subscribeFundingAgreementData()
    
    subscribeLinkedAccounts()
    
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
  
  func subscribeACHInformation() {
    dashboardRepository
      .$achInformationData
      .receive(on: DispatchQueue.main)
      .sink { [weak self] achModel in
        self?.isLoadingACH = achModel.loading
        self?.achInformation = achModel.model
      }
      .store(in: &cancellable)
  }
  
  func subscribeLinkedAccounts() {
    accountDataManager.subscribeLinkedSourcesChanged { [weak self] entities in
      guard let self = self else { return }
      let linkedSources = entities.compactMap({ APILinkedSourceData(entity: $0) })
      self.linkedAccount = linkedSources
    }
    .store(in: &cancellable)
  }
  
  func subscribeFundingAgreementData() {
    addFundsViewModel.fundingAgreementData
      .receive(on: DispatchQueue.main)
      .sink { [weak self] agreementData in
        self?.openFundingAgreement(data: agreementData)
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
  
  func handleFundingAcceptAgreement(isAccept: Bool) {
    if isAccept {
      addFundsViewModel.goNextNavigation()
    } else {
      addFundsViewModel.stopAction()
    }
  }
  
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
  
  func openTaxes() {
    navigation = .taxes
  }
  
  func openFundingAgreement(data: APIAgreementData?) {
    if data == nil {
      navigation = nil
    } else {
      navigation = .agreement(data)
    }
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
}

  // MARK: - API
extension AccountViewModel {
  func getATMAuthorizationCode() {
    Task {
      defer {
        isLoadingAuthorization = false
        isDisableView = false
      }
      isLoadingAuthorization = true
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
    case taxes
    case wallet(asset: AssetModel)
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
