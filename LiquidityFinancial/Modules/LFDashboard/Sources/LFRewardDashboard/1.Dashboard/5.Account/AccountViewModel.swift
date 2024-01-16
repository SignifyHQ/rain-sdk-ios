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
import SolidData
import SolidDomain
import AccountService
import DevicesData
import DevicesDomain

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
  @LazyInjected(\.externalFundingDataManager) var externalFundingDataManager
  @LazyInjected(\.environmentService) var environmentService
  
  @Published var navigation: Navigation?
  @Published var isDisableView: Bool = false
  @Published var isLoadingACH: Bool = false
  @Published var isLoadingLinkedSources: Bool = false
  @Published var isLoading: Bool = false
  @Published var openLegal = false
  @Published var notificationsEnabled = false
  @Published var toastMessage: String?
  @Published var achInformation: ACHModel = .default
  @Published var sheet: Sheet?
  @Published var linkedContacts: [LinkedSourceContact] = []
  
  @Injected(\.solidAccountRepository) var solidAccountRepository
  @Injected(\.devicesRepository) var devicesRepository
  @Injected(\.solidExternalFundingRepository) var solidExternalFundingRepository
  @Injected(\.fiatAccountService) var fiatAccountService
  
  lazy var solidGetWireTransfer: SolidGetWireTranferUseCaseProtocol = {
    SolidGetWireTranferUseCase(repository: solidExternalFundingRepository)
  }()
  
  lazy var deviceRegisterUseCase: DeviceRegisterUseCaseProtocol = {
    DeviceRegisterUseCase(repository: devicesRepository)
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
    subscribeLinkedContacts()
    checkNotificationsStatus()
  }
  
  func onAppear() {
    handleACHData()
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
    checkNotificationsStatus { @MainActor [weak self] status in
      self?.notificationsEnabled = status
    }
  }
  
  func subscribeLinkedContacts() {
    externalFundingDataManager.subscribeLinkedSourcesChanged({ [weak self] contacts in
      self?.linkedContacts = contacts.filter { $0.sourceType == .bank }
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
    case depositLimits
    case connectedAccounts
    case bankStatement
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

// MARK: - ACH
extension AccountViewModel {
  func handleACHData() {
    guard
      achInformation.accountNumber == Constants.Default.undefined.rawValue ||
        achInformation.routingNumber == Constants.Default.undefined.rawValue
    else { return }
    
    Task { @MainActor in
      do {
        defer { isLoadingACH = false }
        isLoadingACH = true
        
        let achModel = try await getACHInformation()
        achInformation = achModel
        
      } catch {
        log.error(error.userFriendlyMessage)
      }
    }
  }
  
  private func getFiatAccounts() async throws -> [AccountModel] {
    let accounts = try await fiatAccountService.getAccounts()
    self.accountDataManager.addOrUpdateAccounts(accounts)
    return accounts
  }
  
  private func getACHInformation() async throws -> ACHModel {
    var account = self.accountDataManager.fiatAccounts.first
    if account == nil {
      account = try await getFiatAccounts().first
    }
    guard let accountId = account?.id else {
      return ACHModel.default
    }
    let wireResponse = try await solidGetWireTransfer.execute(accountId: accountId)
    return ACHModel(
      accountNumber: wireResponse.accountNumber,
      routingNumber: wireResponse.routingNumber,
      accountName: wireResponse.accountNumber
    )
  }
}

// MARK: Notification
extension AccountViewModel {
  func checkNotificationsStatus(completion: @escaping (Bool) -> Void) {
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
