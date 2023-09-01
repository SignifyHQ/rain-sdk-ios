import Factory
import AccountData
import LFUtilities
import AccountDomain
import NetSpendData
import Combine
import LFBank
import LFCard

@MainActor
public final class DashboardRepository: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.netspendRepository) var netspendRepository
  @LazyInjected(\.externalFundingRepository) var externalFundingRepository
  @LazyInjected(\.cardRepository) var cardRepository
  
  @Published public var isLoading: Bool = false
  @Published public var allAssets: [AssetModel] = []
  @Published public var fiatAccounts: [LFAccount] = []
  @Published public var cryptoAccounts: [LFAccount] = []
  @Published public var linkedAccount: [APILinkedSourceData] = []
  
  @Published public var cardData: CardData = CardData(cards: [], metaDatas: [], loading: true)
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
    apiFetchListCard()
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
  
  func apiFetchListCard() {
    cardData.loading = true
    Task {
      do {
        let cards = try await cardRepository.getListCard()
        cardData.cards = cards.map { card in
          CardModel(
            id: card.id,
            cardType: CardType(rawValue: card.type) ?? .virtual,
            cardholderName: nil,
            expiryMonth: card.expirationMonth,
            expiryYear: card.expirationYear,
            last4: card.panLast4,
            cardStatus: CardStatus(rawValue: card.status) ?? .unactivated
          )
        }
        cardData.metaDatas = Array(repeating: nil, count: cardData.cards.count)
        cardData.cards.map { $0.id }.enumerated().forEach { index, id in
          apiFetchCardDetail(with: id, and: index)
        }
      } catch {
        cardData.loading = false
        toastMessage(error.localizedDescription)
      }
    }
    
    func apiFetchCardDetail(with cardID: String, and index: Int) {
      Task {
        defer { cardData.loading = false }
        do {
          let card = try await cardRepository.getCard(cardID: cardID, sessionID: accountDataManager.sessionID)
          if let usersession = netspendDataManager.sdkSession {
            let encryptedData: APICardEncrypted? = card.decodeData(session: usersession)
            if let encryptedData {
              cardData.metaDatas[index] = CardMetaData(pan: encryptedData.pan, cvv: encryptedData.cvv2)
            }
          }
        } catch {
          toastMessage(error.localizedDescription)
        }
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
