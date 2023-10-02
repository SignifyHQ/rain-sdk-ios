import Foundation
import Factory
import AccountData
import LFUtilities
import AccountDomain
import NetSpendData
import Combine
import LFBank
import LFCard
import LFAccountOnboarding
import OnboardingDomain
import LFServices
import DevicesData

extension Container {
  public var dashboardRepository: Factory<DashboardRepository> {
    self {
      DashboardRepository()
    }.singleton
  }
}

public final class DashboardRepository: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.nsPersionRepository) var nsPersionRepository
  @LazyInjected(\.onboardingRepository) var onboardingRepository
  @LazyInjected(\.externalFundingRepository) var externalFundingRepository
  @LazyInjected(\.cardRepository) var cardRepository
  
  @LazyInjected(\.onboardingFlowCoordinator) var onboardingFlowCoordinator
  
  @LazyInjected(\.pushNotificationService) var pushNotificationService
  @LazyInjected(\.devicesRepository) var devicesRepository
  
  @LazyInjected(\.analyticsService) var analyticsService
  
  @Published public var isLoading: Bool = false
  @Published public var allAssets: [AssetModel] = []
  @Published public var fiatAccounts: [LFAccount] = []
  @Published public var cryptoAccounts: [LFAccount] = []
  @Published public var linkedAccount: [APILinkedSourceData] = []
  
  @Published public var cardData: CardData = CardData(cards: [], metaDatas: [], loading: true)
  @Published public var achInformationData: (model: ACHModel, loading: Bool) = (.default, false)
  @Published public var featureConfig: AccountFeatureConfigData = AccountFeatureConfigData(configJSON: "", isLoading: false)
  
  private var cancellable: Set<AnyCancellable> = []
  
  lazy var accountUseCase: AccountUseCase = {
    AccountUseCase(repository: accountRepository)
  }()
  
  var toastMessage: ((String) -> Void)?
  
  init() {}
  
  public init(toastMessage: @escaping (String) -> Void) {
    self.toastMessage = toastMessage
    switch LFUtilities.target {
    case .CauseCard, .PrideCard:
      initRewardData()
    default:
      initData()
    }
    subscribeLinkedAccounts()
    refreshListCards()
  }
  
  public func load(toastMessage: @escaping (String) -> Void) {
    self.toastMessage = toastMessage
    switch LFUtilities.target {
    case .CauseCard, .PrideCard:
      initRewardData()
    default:
      initData()
    }
    subscribeLinkedAccounts()
    refreshListCards()
  }
}

  // MARK: API init data tab content
public extension DashboardRepository {
  
  func initRewardData() {
    apiFetchListConnectedAccount()
    apiFetchACHInfo()
    apiFetchListCard()
    apiFetchFetureConfig()
  }
  
  func initData() {
    apiFetchAssetFromAccounts()
    apiFetchListConnectedAccount()
    apiFetchACHInfo()
    apiFetchListCard()
    apiFetchFetureConfig()
  }
  
  func refreshListCards() {
    NotificationCenter.default.publisher(for: .refreshListCards)
      .sink { [weak self] _ in
        guard let self else { return }
        self.apiFetchListCard()
      }
      .store(in: &cancellable)
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
    Task { @MainActor in
      defer { isLoading = false }
      isLoading = true
      do {
        let sessionID = self.accountDataManager.sessionID
        apiFetchListCard()
        async let fiatAccountsEntity = self.accountRepository.getAccount(currencyType: Constants.CurrencyType.fiat.rawValue)
        
        async let linkedAccountEntity = self.externalFundingRepository.getLinkedAccount(sessionId: sessionID)
        
        let fiatAccounts = try await fiatAccountsEntity
        let linkedSources = try await linkedAccountEntity.linkedSources
        
        self.fiatAccounts = fiatAccounts
        
        self.accountDataManager.storeLinkedSources(linkedSources)
        self.accountDataManager.addOrUpdateAccounts(fiatAccounts)
      } catch {
        log.error(error.localizedDescription)
        toastMessage?(error.localizedDescription)
      }
    }
  }
  
  func apiFetchListCard() {
    cardData.loading = true
    Task { @MainActor in
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
        let filteredCards = cardData.cards.filter({ $0.cardStatus != .closed })
        if filteredCards.isEmpty {
          NotificationCenter.default.post(name: .noLinkedCards, object: nil)
        } else {
          cardData.metaDatas = Array(repeating: nil, count: filteredCards.count)
          filteredCards.map { $0.id }.enumerated().forEach { index, id in
            apiFetchCardDetail(with: id, and: index)
          }
        }
      } catch {
        cardData.loading = false
        toastMessage?(error.localizedDescription)
      }
    }
    
    @Sendable func apiFetchCardDetail(with cardID: String, and index: Int) {
      Task { @MainActor in
        defer { cardData.loading = false }
        do {
          let entity = try await cardRepository.getCard(cardID: cardID, sessionID: accountDataManager.sessionID)
          if let usersession = netspendDataManager.sdkSession, let cardModel = entity as? APICard {
            let encryptedData: APICardEncrypted? = cardModel.decodeData(session: usersession)
            if let encryptedData {
              cardData.metaDatas[index] = CardMetaData(pan: encryptedData.pan, cvv: encryptedData.cvv2)
            }
          }
        } catch {
          toastMessage?(error.localizedDescription)
        }
      }
    }
  }
  
  func apiFetchAssetFromAccounts() {
    Task { @MainActor in
      defer { isLoading = false }
      isLoading = true
      do {
        async let fiatAccountsEntity = self.accountRepository.getAccount(currencyType: Constants.CurrencyType.fiat.rawValue)
        async let cryptoAccountsEntity = self.accountRepository.getAccount(currencyType: Constants.CurrencyType.crypto.rawValue)
        let fiatAccounts = try await fiatAccountsEntity
        let cryptoAccounts = try await cryptoAccountsEntity
        let accounts = fiatAccounts + cryptoAccounts
        let assets = accounts.map { AssetModel(account: $0) }
        
        analyticsService.set(params: [PropertiesName.cashBalance.rawValue: fiatAccounts.first?.availableBalance ?? "0"])
        analyticsService.set(params: [PropertiesName.cryptoBalance.rawValue: cryptoAccounts.first?.availableBalance ?? "0"])
        
        self.fiatAccounts = fiatAccounts
        self.cryptoAccounts = cryptoAccounts
        
        self.allAssets = assets
        self.accountDataManager.accountsSubject.send(accounts)
      } catch {
        log.error(error.localizedDescription)
        toastMessage?(error.localizedDescription)
      }
    }
  }
  
  func apiFetchListConnectedAccount() {
    Task { @MainActor in
      do {
        let sessionID = self.accountDataManager.sessionID
        let response = try await self.externalFundingRepository.getLinkedAccount(sessionId: sessionID)
        self.accountDataManager.storeLinkedSources(response.linkedSources)
      } catch {
        log.error(error.localizedDescription)
        toastMessage?(error.localizedDescription)
      }
    }
  }
  
  func apiFetchACHInfo() {
    Task { @MainActor in
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
        toastMessage?(error.localizedDescription)
      }
    }
  }
  
  func apiFetchFetureConfig() {
    Task { @MainActor in
      do {
        defer {featureConfig.isLoading = false }
        featureConfig.isLoading = true
        let entity = try await accountUseCase.getFeatureConfig()
        featureConfig.configJSON = entity.config ?? ""
      } catch {
        log.error(error.localizedDescription)
        toastMessage?(error.localizedDescription)
      }
    }
  }
}
