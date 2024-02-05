import AccountDomain
import AccountData
import NetSpendData
import LFUtilities
import Factory
import GeneralFeature
import Combine
import AccountService
import SolidFeature
import SolidDomain
import SolidData
import Dispatch
import ExternalFundingData
import NotificationCenter

@MainActor
class CashAssetViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.externalFundingRepository) var externalFundingRepository
  @LazyInjected(\.fiatAccountService) var fiatAccountService
  @LazyInjected(\.solidExternalFundingRepository) var solidExternalFundingRepository
  @LazyInjected(\.externalFundingDataManager) var externalFundingDataManager
  @LazyInjected(\.solidCardRepository) var solidCardRepository
  @LazyInjected(\.featureFlagManager) var featureFlagManager
  
  @Published var assetModel: AssetModel?
  @Published var isDisableView: Bool = false
  @Published var showTransferSheet: Bool = false
  @Published var cryptoPrice: String = "0.00"
  @Published var changePercent: Double = 0
  @Published var showCryptoDetail: Bool = false
  @Published var toastMessage: String = ""
  @Published var navigation: Navigation?
  @Published var activity = Activity.loading
  @Published var transactions: [TransactionModel] = []
  @Published var fullScreen: FullScreen?
  @Published var isLoadingACH: Bool = false
  @Published var achInformation: ACHModel = .default
  @Published var linkedContacts: [LinkedSourceContact] = []
  
  let currencyType = Constants.CurrencyType.fiat.rawValue
  private(set) var cardsList: [CardModel] = []
  private(set) var filteredCardsList: [CardModel] = []
  
  private(set) var addFundsViewModel = AddFundsViewModel()
  private var cancellable: Set<AnyCancellable> = []
  
  lazy var solidGetWireTransfer: SolidGetWireTranferUseCaseProtocol = {
    SolidGetWireTranferUseCase(repository: solidExternalFundingRepository)
  }()
  
  lazy var getListSolidCardUseCase: SolidGetListCardUseCaseProtocol = {
    SolidGetListCardUseCase(repository: solidCardRepository)
  }()

  var usdBalance: String {
    assetModel?.availableBalanceFormatted ?? .empty
  }
  
  var title: String {
    assetModel?.type?.title ?? .empty
  }
  
  init() {
    apiFetchSolidCards()
    subscribeLinkedContacts()
    subscribeAssetChange()
    handleACHData()
    observeDidCardsListChangeNotification()
  }
}

// MARK: - Private Functions
private extension CashAssetViewModel {
  private func apiFetchSolidCards(completion: (() -> Void)? = nil) {
    Task {
      defer {
        completion?()
      }
      
      do {
        let cards = try await getListSolidCardUseCase.execute(isContainClosedCard: true)
        cardsList = mapToListCardModel(from: cards)
        filteredCardsList = cardsList.filter({ $0.cardStatus != .closed })
      } catch {
        toastMessage = error.userFriendlyMessage
      }
    }
  }
  
  func handleACHData() {
    guard
      achInformation.accountNumber == Constants.Default.undefined.rawValue ||
        achInformation.routingNumber == Constants.Default.undefined.rawValue else {
      return
    }
    
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
  
  private func getFiatAccounts() async throws -> [AccountModel] {
    let accounts = try await fiatAccountService.getAccounts()
    self.accountDataManager.addOrUpdateAccounts(accounts)
    return accounts
  }
  
  func getAccountDetail(id: String) async {
    do {
      let account = try await fiatAccountService.getAccountDetail(id: id)
      self.accountDataManager.fiatAccountID = account.id
      self.accountDataManager.addOrUpdateAccount(account)
    } catch {
      toastMessage = error.userFriendlyMessage
    }
  }
  
  func loadTransactions(accountId: String) async {
    do {
      let transactions = try await accountRepository.getTransactions(
        accountId: accountId,
        currencyType: currencyType,
        transactionTypes: Constants.TransactionTypesRequest.fiat.types,
        limit: 20,
        offset: 0
      )
      let transactionsModel = transactions.data.compactMap({ TransactionModel(from: $0) })
      if transactionsModel.isEmpty {
        activity = .empty
      } else {
        self.transactions = transactionsModel
        activity = .transactions
      }
    } catch {
      toastMessage = error.userFriendlyMessage
      activity = .failure
    }
  }
  
  func subscribeLinkedContacts() {
    externalFundingDataManager.subscribeLinkedSourcesChanged({ [weak self] contacts in
      self?.linkedContacts = contacts
    })
    .store(in: &cancellable)
  }
  
  func subscribeAssetChange() {
    accountDataManager
      .accountsSubject
      .receive(on: DispatchQueue.main)
      .compactMap({ [weak self] (accounts: [AccountModel]) -> AssetModel? in
        guard let model = accounts.first(where: { model in
          model.currency == .USD
        }) else {
          self?.clearData()
          return nil
        }
        return AssetModel(account: model)
      })
    .assign(to: \.assetModel, on: self)
    .store(in: &cancellable)
  }
  
  func observeDidCardsListChangeNotification() {
    NotificationCenter.default.publisher(for: .didCardsListChange)
      .sink { [weak self] notification in
        guard let self, let cardsList = notification.userInfo?[Constants.UserInfoKey.cards] as? [CardModel] else {
          return
        }
        self.cardsList = cardsList
        self.filteredCardsList = cardsList.filter({ $0.cardStatus != .closed })
      }
      .store(in: &cancellable)
  }
  
  func mapToListCardModel(from entities: [SolidCardEntity]) -> [CardModel] {
    entities.map {
      CardModel(
        id: $0.id,
        cardName: ($0.name?.isEmpty ?? true) ? "Card \($0.panLast4)" : $0.name,
        cardType: CardType(rawValue: $0.type) ?? .virtual,
        cardholderName: nil,
        expiryMonth: Int($0.expirationMonth) ?? 0,
        expiryYear: Int($0.expirationYear) ?? 0,
        last4: $0.panLast4,
        popularBackgroundColor: nil, // TODO: MinhNguyen - Update in phase 3
        popularTextColor: nil, // TODO: MinhNguyen - Update in phase 3
        cardStatus: CardStatus(rawValue: $0.cardStatus) ?? .unactivated
      )
    }
  }
}

// MARK: - View Helpers
extension CashAssetViewModel {
  func clearData() {
    assetModel = nil
    activity = .empty
    cardsList = []
    filteredCardsList = []
    achInformation = .default
    linkedContacts = []
  }
  
  func refreshData() {
    Task {
      await refresh()
    }
  }
  
  func refresh() async {
    guard let id = self.assetModel?.id else {
      return
    }
    await withTaskGroup(of: Void.self) { group in
      group.addTask {
        await self.getAccountDetail(id: id)
      }
      group.addTask {
        await self.loadTransactions(accountId: id)
      }
      group.addTask {
        await self.apiFetchSolidCards()
      }
    }
  }
  
  func addMoneyTapped() {
    Haptic.impact(.light).generate()
    if linkedContacts.isEmpty {
      fullScreen = .fundCard(.receive)
    } else {
      navigation = .addMoney
    }
  }
  
  func sendMoneyTapped() {
    Haptic.impact(.light).generate()
    if linkedContacts.isEmpty {
      fullScreen = .fundCard(.send)
    } else {
      navigation = .sendMoney
    }
  }
  
  func onClickedSeeAllButton() {
    navigation = .transactions
  }
  
  func transactionItemTapped(_ transaction: TransactionModel) {
    Haptic.impact(.light).generate()
    navigation = .transactionDetail(transaction)
  }
  
  func accountRountingTapped() {
    navigation = .accountRounting
  }
  
  func fundingAccountTapped() {
    navigation = .fundingAccount
  }
  
  func depositWithdrawalLimitsTapped() {
    navigation = .depositWithdrawalLimits
  }
  
  func bankStatementsTapped() {
    navigation = .bankStatements
  }
  
  func seeAllConnectedCards() {
    navigation = .allCards
  }
  
  func navigateToCardDetail(card: CardModel) {
    if featureFlagManager.isFeatureFlagEnabled(.virtualCardPhrase1) {
      let viewModel = CardDetailViewModel(
        currentCard: card,
        cardsList: cardsList,
        filterredCards: filteredCardsList
      )
      navigation = .cardDetail(viewModel)
      return
    }
    
    let viewModel = SolidListCardsViewModel(selectCardId: card.id)
    navigation = .cardListDetail(viewModel)
  }
}

// MARK: - Types
extension CashAssetViewModel {
  enum Activity {
    case loading
    case failure
    case empty
    case transactions
  }
  
  enum Navigation {
    case addMoney
    case sendMoney
    case transactions
    case transactionDetail(TransactionModel)
    case accountRounting
    case fundingAccount
    case depositWithdrawalLimits
    case allCards
    case cardDetail(CardDetailViewModel)
    case bankStatements
    case cardListDetail(SolidListCardsViewModel)
  }
  
  enum FullScreen: Identifiable {
    case fundCard(MoveMoneyAccountViewModel.Kind)

    var id: String {
      switch self {
      case .fundCard: return "fundCard"
      }
    }
  }
}
