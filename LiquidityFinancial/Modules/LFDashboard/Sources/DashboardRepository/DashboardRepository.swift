import Factory
import AccountData
import LFUtilities
import AccountDomain
import NetSpendData
import Combine
import LFBank

@MainActor
public final class DashboardRepository: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.netspendRepository) var netspendRepository
  @LazyInjected(\.externalFundingRepository) var externalFundingRepository
  
  @Published public var isLoading: Bool = false
  @Published public var allAssets: [AssetModel] = []
  @Published public var fiatAccounts: [LFAccount] = []
  @Published public var cryptoAccounts: [LFAccount] = []
  @Published public var linkedAccount: [APILinkedSourceData] = []
  
  @Published public var achInformationData: (model: ACHModel, loading: Bool) = (.default, false)
  
  private var cancellable: Set<AnyCancellable> = []
  
  var toastMessage: (String) -> Void
  public init(toastMessage: @escaping (String) -> Void) {
    self.toastMessage = toastMessage
    initData()
    subscribeLinkedAccounts()
  }
}

  // MARK: API init data tab content
public extension DashboardRepository {
  
  func initData() {
    apiFetchAssetFromAccounts()
    apiFetchListConnectedAccount()
    apiFetchACHInfo()
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
  
  func refreshCash() {
    Task {
      defer { isLoading = false }
      isLoading = true
      do {
        let sessionID = self.accountDataManager.sessionID
        
        async let fiatAccountsEntity = self.accountRepository.getAccount(currencyType: Constants.CurrencyType.fiat.rawValue)
        
        async let linkedAccountEntity = self.externalFundingRepository.getLinkedAccount(sessionId: sessionID)
        
        let fiatAccounts = try await fiatAccountsEntity
        let linkedSources = try await linkedAccountEntity.linkedSources
        
        
        self.fiatAccounts = fiatAccounts
        self.accountDataManager.storeLinkedSources(linkedSources)
      } catch {
        log.error(error.localizedDescription)
        toastMessage(error.localizedDescription)
      }
    }
  }
  
  func apiFetchAssetFromAccounts() {
    Task {
      defer { isLoading = false }
      isLoading = true
      do {
        async let fiatAccountsEntity = self.accountRepository.getAccount(currencyType: Constants.CurrencyType.fiat.rawValue)
        async let cryptoAccountsEntity = self.accountRepository.getAccount(currencyType: Constants.CurrencyType.crypto.rawValue)
        let fiatAccounts = try await fiatAccountsEntity
        let cryptoAccounts = try await cryptoAccountsEntity
        let accounts = fiatAccounts + cryptoAccounts
        let assets = accounts.map {
          AssetModel(
            type: AssetType(rawValue: $0.currency),
            availableBalance: $0.availableBalance,
            availableUsdBalance: $0.availableUsdBalance
          )
        }
        self.fiatAccounts = fiatAccounts
        self.cryptoAccounts = cryptoAccounts
        self.allAssets = assets
      } catch {
        log.error(error.localizedDescription)
        toastMessage(error.localizedDescription)
      }
    }
  }
  
  func apiFetchListConnectedAccount() {
    Task {
      do {
        let sessionID = self.accountDataManager.sessionID
        let response = try await self.externalFundingRepository.getLinkedAccount(sessionId: sessionID)
        self.accountDataManager.storeLinkedSources(response.linkedSources)
      } catch {
        log.error(error.localizedDescription)
        toastMessage(error.localizedDescription)
      }
    }
  }
  
  func apiFetchACHInfo() {
    Task {
      defer { achInformationData.loading = false }
      achInformationData.loading = true
      do {
        let achResponse = try await externalFundingRepository.getACHInfo(sessionID: accountDataManager.sessionID)
        let achInformation = ACHModel(
          accountNumber: achResponse.accountNumber ?? Constants.Default.undefined.rawValue,
          routingNumber: achResponse.routingNumber ?? Constants.Default.undefined.rawValue,
          accountName: achResponse.accountName ?? Constants.Default.undefined.rawValue
        )
        achInformationData.model = achInformation
      } catch {
        toastMessage(error.localizedDescription)
      }
    }
  }
}
