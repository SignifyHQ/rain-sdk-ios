import Combine
import Foundation
import UIKit
import LFUtilities
import Factory
import NetSpendData
import NetSpendDomain
import NetspendSdk
import LFBank
import BaseDashboard
import AccountDomain
import AccountData

@MainActor
class AccountViewModel: ObservableObject {
  @LazyInjected(\.netspendRepository) var netspendRepository
  @LazyInjected(\.externalFundingRepository) var externalFundingRepository
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.intercomService) var intercomService
  @LazyInjected(\.pushNotificationService) var pushNotificationService
  @LazyInjected(\.devicesRepository) var devicesRepository
  
  @Published var navigation: Navigation?
  
  @Published var isDisableView: Bool = false
  @Published var isLoadingACH: Bool = false
  @Published var isLoadingDisputeTransaction: Bool = false
  @Published var isLoading: Bool = false
  @Published var notificationsEnabled = false
  @Published var sheet: Sheet?
  @Published var isLoadingAssets: Bool = false
  
  @Published var netspendController: NetspendSdkViewController?
  @Published var toastMessage: String?
  @Published var linkedAccount: [APILinkedSourceData] = []
  @Published var achInformation: ACHModel = .default
  @Published var assets: [AssetModel] = []
  
  private(set) var addFundsViewModel = AddFundsViewModel()
  
  private var cancellable: Set<AnyCancellable> = []
  
  var networkEnvironment: NetworkEnvironment {
    EnvironmentManager().networkEnvironment
  }
  
  init(achInformationData: Published<(model: ACHModel, loading: Bool)>.Publisher, accountsCrypto: Published<[LFAccount]>.Publisher) {
    
    accountsCrypto
      .receive(on: DispatchQueue.main)
      .sink { [weak self] accounts in
        let assets = accounts.compactMap({
          AssetModel(
            id: $0.id,
            type: AssetType(rawValue: $0.currency),
            availableBalance: $0.availableBalance,
            availableUsdBalance: $0.availableUsdBalance,
            externalAccountId: $0.externalAccountId
          )
        })
        self?.assets = assets
      }
      .store(in: &cancellable)
    
    achInformationData
      .receive(on: DispatchQueue.main)
      .sink { [weak self] achModel in
        self?.isLoadingACH = achModel.loading
        self?.achInformation = achModel.model
      }
      .store(in: &cancellable)
    
    handleFundingAgreementData()
    
    subscribeLinkedAccounts()
    checkNotificationsStatus()
  }
  
  func subscribeLinkedAccounts() {
    accountDataManager.subscribeLinkedSourcesChanged { [weak self] entities in
      guard let self = self else {
        return
      }
      let linkedSources = entities.compactMap({ APILinkedSourceData(entity: $0) })
      self.linkedAccount = linkedSources
    }
    .store(in: &cancellable)
  }
  
  func getSubWalletAddress(asset: AssetModel) -> String {
    var walletAdress = ""
    if let externalAccountId = asset.externalAccountId {
      walletAdress = externalAccountId.substring(start: 0, end: externalAccountId.count / 4)
    }
    return walletAdress
  }
}

  // MARK: - View Helpers
extension AccountViewModel {
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
  
  func selectedAddOption(navigation: Navigation) {
    self.navigation = navigation
  }
  
  func connectedAccountsTapped() {
    navigation = .connectedAccounts
  }
  
  func bankStatementTapped() {
    navigation = .bankStatement
  }
  
  func openIntercomService() {
    intercomService.openIntercom()
  }
  
  func openTaxes() {
    navigation = .taxes
  }
  
  func openFundingAgreement(data: APIAgreementData?) {
    if data == nil {
      sheet = nil
    } else {
      sheet = .agreement(data)
    }
  }
  
  func openLegal() {
    sheet = .legal
  }
  
  func openWalletAddress(asset: AssetModel) {
    navigation = .wallet(asset: asset)
  }
  
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
        if token == UserDefaults.lastestFCMToken {
          return
        }
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

  // MARK: - API
extension AccountViewModel {
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
        let code = try await netspendRepository.getAuthorizationCode(sessionId: sessionID)
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
        let code = try await netspendRepository.getAuthorizationCode(sessionId: session.sessionId)
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
    case connectedAccounts
    case bankStatement
    case disputeTransaction(String, String)
    case taxes
    case wallet(asset: AssetModel)
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
      case .agreement: return 1
      }
    }
    var id: Self {
      self
    }
    case legal
    case agreement(APIAgreementData?)
  }
}
