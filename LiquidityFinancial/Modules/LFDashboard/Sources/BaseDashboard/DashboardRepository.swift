import Foundation
import Factory
import AccountData
import LFUtilities
import AccountDomain
import NetSpendData
import Combine
import LFBaseBank
import BaseCard
import NetspendOnboarding
import OnboardingDomain
import LFServices
import DevicesData
import DevicesDomain
import NetspendDomain
import ExternalFundingData
import SolidData
import SolidDomain

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
  @LazyInjected(\.externalFundingDataManager) var externalFundingDataManager
  
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.nsPersonRepository) var nsPersonRepository
  @LazyInjected(\.onboardingRepository) var onboardingRepository
  @LazyInjected(\.externalFundingRepository) var externalFundingRepository
  @LazyInjected(\.cardRepository) var cardRepository
  
  @LazyInjected(\.solidAccountRepository) var solidAccountRepository
  @LazyInjected(\.solidExternalFundingRepository) var solidExternalFundingRepository
  
  @LazyInjected(\.nsOnboardingFlowCoordinator) var onboardingFlowCoordinator
  
  @LazyInjected(\.pushNotificationService) var pushNotificationService
  @LazyInjected(\.devicesRepository) var devicesRepository
  
  @LazyInjected(\.analyticsService) var analyticsService
  
  @Published public var fiatData: (fiatAccount: [LFAccount], loading: Bool) = ([], false)
  @Published public var cryptoData: (cryptoAccounts: [LFAccount], loading: Bool) = ([], false)
  
  @Published public var isLoadingRewardTab: Bool = false
  
  @Published public var netspendCardData: CardData = CardData(cards: [], metaDatas: [], loading: true)
  @Published public var solidCardData: CardData = CardData(cards: [], metaDatas: [], loading: true)
  @Published public var achInformationData: (model: ACHModel, loading: Bool) = (.default, false)
  @Published public var featureConfig: AccountFeatureConfigData = AccountFeatureConfigData(configJSON: "", isLoading: false)
  
  private var cancellable: Set<AnyCancellable> = []
  
  lazy var accountUseCase: AccountUseCase = {
    AccountUseCase(repository: accountRepository)
  }()
  
  lazy var deviceRegisterUseCase: DeviceRegisterUseCaseProtocol = {
    DeviceRegisterUseCase(repository: devicesRepository)
  }()
  
  lazy var solidGetAccountUseCase: SolidGetAccountsUseCaseProtocol = {
    SolidGetAccountsUseCase(repository: solidAccountRepository)
  }()
  
  lazy var solidGetLinkedSourcesUseCase: SolidGetLinkedSourcesUseCaseProtocol = {
    SolidGetLinkedSourcesUseCase(repository: solidExternalFundingRepository)
  }()
  
  lazy var solidGetWireTransfer: SolidGetWireTranferUseCaseProtocol = {
    SolidGetWireTranferUseCase(repository: solidExternalFundingRepository)
  }()
  
  lazy var unlinkContactUseCase: SolidUnlinkContactUseCaseProtocol = {
    SolidUnlinkContactUseCase(repository: solidExternalFundingRepository)
  }()
  
  lazy var getListCardUseCase: NSGetListCardUseCaseProtocol = {
    NSGetListCardUseCase(repository: cardRepository)
  }()
  
  lazy var getCardUseCase: NSGetCardUseCaseProtocol = {
    NSGetCardUseCase(repository: cardRepository)
  }()
  
  lazy var nsGetACHInfoUseCase: NSGetACHInfoUseCaseProtocol = {
    NSGetACHInfoUseCase(repository: externalFundingRepository)
  }()
  
  lazy var nsGetLinkedAccountUseCase: NSGetLinkedAccountUseCaseProtocol = {
    NSGetLinkedAccountUseCase(repository: externalFundingRepository)
  }()
  
  lazy var getQuestionUseCase: NSGetQuestionUseCaseProtocol = {
    NSGetQuestionUseCase(repository: nsPersonRepository)
  }()
  
  lazy var getDocumentUseCase: NSGetDocumentsUseCaseProtocol = {
    NSGetDocumentsUseCase(repository: nsPersonRepository)
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
    refreshListCards()
  }
}

  // MARK: API init data tab content
public extension DashboardRepository {
  
  func initRewardData() {
    apiFetchListConnectedAccount()
    apiFetchACHInfo()
    apiFetchSolidCards()
    apiFetchFetureConfig()
  }
  
  func initData() {
    apiFetchAssetFromAccounts()
    apiFetchListConnectedAccount()
    apiFetchACHInfo()
    apiFetchNetSpendCards()
    apiFetchFetureConfig()
  }
  
  func refreshListCards() {
    NotificationCenter.default.publisher(for: .refreshListCards)
      .sink { [weak self] _ in
        guard let self else { return }
        self.apiFetchListCards()
      }
      .store(in: &cancellable)
  }
  
  func refreshCash() {
    Task { @MainActor in
      defer { fiatData.loading = false }
      fiatData.loading = true
      do {
        apiFetchListCards()
        
        let fiatAccounts = try await getFiatAccounts()
        self.fiatData.fiatAccount = fiatAccounts
        self.accountDataManager.addOrUpdateAccounts(fiatAccounts)
      } catch {
        log.error(error.localizedDescription)
        toastMessage?(error.localizedDescription)
      }
    }
  }
  
  func apiFetchListCards() {
    switch LFUtilities.target {
    case .CauseCard, .PrideCard:
      apiFetchSolidCards()
    default:
      apiFetchNetSpendCards()
    }
  }
  
  func apiFetchNetSpendCards() {
    netspendCardData.loading = true
    Task { @MainActor in
      do {
        let cards = try await getListCardUseCase.execute()
        netspendCardData.cards = cards.map { card in
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
        let filteredCards = netspendCardData.cards.filter({ $0.cardStatus != .closed })
        if filteredCards.isEmpty {
          NotificationCenter.default.post(name: .noLinkedCards, object: nil)
        } else {
          netspendCardData.metaDatas = Array(repeating: nil, count: filteredCards.count)
          filteredCards.map { $0.id }.enumerated().forEach { index, id in
            apiFetchNetSpendCardDetail(with: id, and: index)
          }
        }
      } catch {
        netspendCardData.loading = false
        toastMessage?(error.localizedDescription)
      }
    }
  }
    
  func apiFetchSolidCards() {
    solidCardData.loading = true
    Task { @MainActor in
      do {
        let cards = try await getListCardUseCase.execute()
        solidCardData.cards = cards.map { card in
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
        let filteredCards = solidCardData.cards.filter({ $0.cardStatus != .closed })
        if filteredCards.isEmpty {
          NotificationCenter.default.post(name: .noLinkedCards, object: nil)
        } else {
          solidCardData.metaDatas = Array(repeating: nil, count: filteredCards.count)
          filteredCards.map { $0.id }.enumerated().forEach { index, id in
            apiFetchSolidCardDetail(with: id, and: index)
          }
        }
      } catch {
        solidCardData.loading = false
        toastMessage?(error.localizedDescription)
      }
    }
  }
  
  @Sendable func apiFetchNetSpendCardDetail(with cardID: String, and index: Int) {
    Task { @MainActor in
      defer { netspendCardData.loading = false }
      do {
        let entity = try await getCardUseCase.execute(cardID: cardID, sessionID: accountDataManager.sessionID)
        if let usersession = netspendDataManager.sdkSession, let cardModel = entity as? APICard {
          let encryptedData: APICardEncrypted? = cardModel.decodeData(session: usersession)
          if let encryptedData {
            netspendCardData.metaDatas[index] = CardMetaData(pan: encryptedData.pan, cvv: encryptedData.cvv2)
          }
        }
      } catch {
        toastMessage?(error.localizedDescription)
      }
    }
  }
  
  @Sendable func apiFetchSolidCardDetail(with cardID: String, and index: Int) {
    Task { @MainActor in
      defer { solidCardData.loading = false }
      do {
        let entity = try await getCardUseCase.execute(cardID: cardID, sessionID: accountDataManager.sessionID)
        if let usersession = netspendDataManager.sdkSession, let cardModel = entity as? APICard {
          let encryptedData: APICardEncrypted? = cardModel.decodeData(session: usersession)
          if let encryptedData {
            solidCardData.metaDatas[index] = CardMetaData(pan: encryptedData.pan, cvv: encryptedData.cvv2)
          }
        }
      } catch {
        toastMessage?(error.localizedDescription)
      }
    }
  }
  
  func apiFetchAssetFromAccounts() {
    Task { @MainActor in
      defer {
        fiatData.loading = false
        cryptoData.loading = false
      }
      isLoadingRewardTab = true
      fiatData.loading = true
      cryptoData.loading = true
      
      do {
        async let cryptoAccountsEntity = self.accountRepository.getAccount(currencyType: Constants.CurrencyType.crypto.rawValue)
        let fiatAccounts = try await getFiatAccounts()
        let cryptoAccounts = try await cryptoAccountsEntity
        let accounts = fiatAccounts + cryptoAccounts
        
        let assets = accounts.map { AssetModel(account: $0) }
        getRewardCurrency(assets: assets)
        
        analyticsService.set(params: [PropertiesName.cashBalance.rawValue: fiatAccounts.first?.availableBalance ?? "0"])
        analyticsService.set(params: [PropertiesName.cryptoBalance.rawValue: cryptoAccounts.first?.availableBalance ?? "0"])
        
        self.fiatData.fiatAccount = fiatAccounts
        self.cryptoData.cryptoAccounts = cryptoAccounts
        
        self.accountDataManager.accountsSubject.send(accounts)
      } catch {
        isLoadingRewardTab = false
        log.error(error.localizedDescription)
        toastMessage?(error.localizedDescription)
      }
    }
  }
  
  private func getRewardCurrency(assets: [AssetModel] = []) {
    Task { @MainActor in
      do {
        let availableRewardCurrencies = try await accountRepository.getAvailableRewardCurrrencies()
        accountDataManager.availableRewardCurrenciesSubject.send(availableRewardCurrencies)
        let selectedRewardCurrency = try await accountRepository.getSelectedRewardCurrency()
        accountDataManager.selectedRewardCurrencySubject.send(selectedRewardCurrency)
        isLoadingRewardTab = false
      } catch {
        guard let errorObject = error.asErrorObject else {
          toastMessage?(error.localizedDescription)
          isLoadingRewardTab = false
          return
        }
        switch errorObject.code {
        case Constants.ErrorCode.accountCreationInProgress.rawValue:
          let availableRewardCurrencies = APIAvailableRewardCurrencies(
            availableRewardCurrencies: assets.compactMap { $0.type?.rawValue }
          )
          accountDataManager.selectedRewardCurrencySubject.send(nil)
          accountDataManager.availableRewardCurrenciesSubject.send(availableRewardCurrencies)
        default:
          toastMessage?(errorObject.message)
        }
        isLoadingRewardTab = false
      }
    }
  }
  
  func apiFetchACHInfo() {
    Task { @MainActor in
      defer { achInformationData.loading = false }
      achInformationData.loading = true
      do {
        let achModel = try await getACHInformation()
        achInformationData.model = achModel
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

// MARK: Account
public extension DashboardRepository {
  
  func getFiatAccounts() async throws -> [LFAccount] {
    switch LFUtilities.target {
    case .CauseCard, .PrideCard:
      let entity = try await solidGetAccountUseCase.execute()
      return entity.map { item in
        APIAccount(id: item.id, externalAccountId: item.externalAccountId, currency: item.currency, availableBalance: item.availableBalance, availableUsdBalance: item.availableUsdBalance)
      }
    default:
      return try await self.accountRepository.getAccount(currencyType: Constants.CurrencyType.fiat.rawValue)
    }
  }
  
  func getACHInformation() async throws -> ACHModel {
    switch LFUtilities.target {
    case .PrideCard:
      var account = self.accountDataManager.accountsSubject.value.first(where: {
        Constants.CurrencyList.fiats.contains($0.currency)
      })
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
    default:
      let achResponse = try await nsGetACHInfoUseCase.execute(sessionID: accountDataManager.sessionID)
      let achInformation = ACHModel(
        accountNumber: achResponse.accountNumber ?? Constants.Default.undefined.rawValue,
        routingNumber: achResponse.routingNumber ?? Constants.Default.undefined.rawValue,
        accountName: achResponse.accountName ?? Constants.Default.undefined.rawValue
      )
      return achInformation
    }
  }
  
}

// MARK: External Funding
public extension DashboardRepository {
  
  func apiFetchListConnectedAccount() {
    switch LFUtilities.target {
    case .CauseCard, .PrideCard:
      fetchSolidLinkedSources()
    default:
      fetchNetspendLinkedSources()
    }
  }
  
}

extension DashboardRepository {
  
  private func fetchNetspendLinkedSources() {
    Task { @MainActor in
      do {
        let sessionID = self.accountDataManager.sessionID
        let response = try await self.nsGetLinkedAccountUseCase.execute(sessionId: sessionID)
        self.accountDataManager.storeLinkedSources(response.linkedSources)
      } catch {
        log.error(error.localizedDescription)
        toastMessage?(error.localizedDescription)
      }
    }
  }
  
}

extension DashboardRepository {
  
  private func removeUnknowContactSources(_ sources: [SolidContactEntity]) {
    Task {
      do {
        for source in sources {
          guard APISolidContactType(rawValue: source.type) == nil else {
            continue
          }
          _ = try? await self.unlinkContactUseCase.execute(id: source.solidContactId)
        }
      } catch {
        log.error(error.localizedDescription)
      }
    }
  }
  
  private func fetchSolidLinkedSources() {
    Task { @MainActor in
      do {
        let accounts = try await self.solidGetAccountUseCase.execute()
        guard let account = accounts.first else {
          return
        }
        let response = try await self.solidGetLinkedSourcesUseCase.execute(accountID: account.id)
        var unknownSources: [SolidContactEntity] = []
        let contacts = response.compactMap({ (data: SolidContactEntity) -> LinkedSourceContact? in
          guard let type = APISolidContactType(rawValue: data.type) else {
            unknownSources.append(data)
            return nil
          }
          let sourceType: LinkedSourceContactType = type == .externalBank ? .bank : .card
          return LinkedSourceContact(name: data.name, last4: data.last4, sourceType: sourceType, sourceId: data.solidContactId)
        })
        self.externalFundingDataManager.storeLinkedSources(contacts)
        self.removeUnknowContactSources(unknownSources)
      } catch {
        log.error(error.localizedDescription)
      }
    }
  }
}
