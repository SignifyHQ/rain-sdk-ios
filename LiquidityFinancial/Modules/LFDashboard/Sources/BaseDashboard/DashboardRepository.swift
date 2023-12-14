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
import Services
import DevicesData
import DevicesDomain
import NetspendDomain
import ExternalFundingData
import SolidData
import SolidDomain
import AccountService

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
  @LazyInjected(\.fiatAccountService) var fiatAccountService
  @LazyInjected(\.cryptoAccountService) var cryptoAccountService
  
  @Published public var fiatData: (fiatAccount: [AccountModel], loading: Bool) = ([], false)
  @Published public var cryptoData: (cryptoAccounts: [AccountModel], loading: Bool) = ([], false)
  
  @Published public var isLoadingRewardTab: Bool = false
  
  @Published public var netspendCardData: CardData = CardData(cards: [], metaDatas: [], loading: true)
  @Published public var solidCardData: CardData = CardData(cards: [], metaDatas: [], loading: true)
  @Published public var achInformationData: (model: ACHModel, loading: Bool) = (.default, false)
  
  private var cancellable: Set<AnyCancellable> = []
  
  lazy var accountUseCase: AccountUseCase = {
    AccountUseCase(repository: accountRepository)
  }()
  
  lazy var deviceRegisterUseCase: DeviceRegisterUseCaseProtocol = {
    DeviceRegisterUseCase(repository: devicesRepository)
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
  
  lazy var getListNSCardUseCase: NSGetListCardUseCaseProtocol = {
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
    initData()
    refreshListCards()
  }
  
  public func load(toastMessage: @escaping (String) -> Void) {
    self.toastMessage = toastMessage
    initData()
    refreshListCards()
  }
}

  // MARK: API init data tab content
public extension DashboardRepository {

  func initData() {
    apiFetchAssetFromAccounts()
    fetchNetspendLinkedSources()
    apiFetchACHInfo()
    apiFetchNetSpendCards()
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
        
        _ = try await getFiatAccounts()
      } catch {
        log.error(error.localizedDescription)
        toastMessage?(error.localizedDescription)
      }
    }
  }
  
  //TODO: We should remove the logic of refreshing the list card after migration of the Crypto App here
  func apiFetchListCards() {
    switch LFUtilities.target {
    case .CauseCard, .PrideCard:
      break
    default:
      apiFetchNetSpendCards()
    }
  }
  
  func apiFetchNetSpendCards() {
    netspendCardData.loading = true
    Task { @MainActor in
      do {
        let cards = try await getListNSCardUseCase.execute()
        netspendCardData.cards = cards.map { card in
          CardModel(
            id: card.liquidityCardId,
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
  
  @Sendable func apiFetchNetSpendCardDetail(with cardID: String, and index: Int) {
    Task { @MainActor in
      defer { netspendCardData.loading = false }
      do {
        let entity = try await getCardUseCase.execute(cardID: cardID, sessionID: accountDataManager.sessionID)
        if let usersession = netspendDataManager.sdkSession, let cardModel = entity as? NSAPICard {
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
        let fiatAccounts = try await self.getFiatAccounts()
        let cryptoAccounts = try await self.getCryptoAccounts()
        let accounts = fiatAccounts + cryptoAccounts
        
        let assets = fiatAccounts.map { AssetModel(account: $0) }
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
}

// MARK: Account
public extension DashboardRepository {
  
  func getFiatAccounts() async throws -> [AccountModel] {
    let accounts = try await fiatAccountService.getAccounts()
    
    self.fiatData.fiatAccount = accounts
    self.accountDataManager.addOrUpdateAccounts(accounts)
    return accounts
  }
  
  func getCryptoAccounts() async throws -> [AccountModel] {
    let accounts = try await cryptoAccountService.getAccounts()
    
    self.cryptoData.cryptoAccounts = accounts
    self.accountDataManager.addOrUpdateAccounts(accounts)
    return accounts
  }
  
  func getACHInformation() async throws -> ACHModel {
    let achResponse = try await nsGetACHInfoUseCase.execute(sessionID: accountDataManager.sessionID)
    let achInformation = ACHModel(
      accountNumber: achResponse.accountNumber ?? Constants.Default.undefined.rawValue,
      routingNumber: achResponse.routingNumber ?? Constants.Default.undefined.rawValue,
      accountName: achResponse.accountName ?? Constants.Default.undefined.rawValue
    )
    return achInformation
  }
  
}

extension DashboardRepository {
  
  public func fetchNetspendLinkedSources() {
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
