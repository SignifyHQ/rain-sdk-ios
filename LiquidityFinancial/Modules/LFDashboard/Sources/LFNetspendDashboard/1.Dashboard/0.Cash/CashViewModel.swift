import Foundation
import NetspendFeature
import Factory
import NetSpendData
import NetspendDomain
import AccountDomain
import AccountData
import LFUtilities
import Combine
import GeneralFeature

@MainActor
final class CashViewModel: ObservableObject {
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.cardRepository) var cardRepository
  
  @Published var isCardActive: Bool = true
  @Published var isLoading: Bool = false
  @Published var isOpeningPlaidView: Bool = false
  @Published var isDisableView: Bool = false
  @Published var cashBalanceValue: Double = 0
  @Published var toastMessage: String?
  @Published var activity = Activity.loading
  @Published var selectedAsset: AssetType = .usd
  @Published var navigation: Navigation?
  @Published var transactions: [TransactionModel] = []
  @Published var assets: [AssetModel] = []
  @Published var linkedAccount: [APILinkedSourceData] = []
  @Published var achInformation: ACHModel = .default
  @Published var fullScreen: FullScreen?
  
  lazy var getListNSCardUseCase: NSGetListCardUseCaseProtocol = {
    NSGetListCardUseCase(repository: cardRepository)
  }()
  
  lazy var getCardUseCase: NSGetCardUseCaseProtocol = {
    NSGetCardUseCase(repository: cardRepository)
  }()
  
  let currencyType = Constants.CurrencyType.fiat.rawValue
  
  //This is flag handle case when app have change scenePhase
  var shouldReloadListTransaction: Bool = false
  
  var transactionLimitEntity: Int {
    20
  }
  
  var transactionLimitOffset: Int {
    0
  }

  private(set) var addFundsViewModel = AddFundsViewModel()
  
  private var cancellable: Set<AnyCancellable> = []
  
  let dashboardRepository: DashboardRepository
  init(dashboardRepository: DashboardRepository) {
    self.dashboardRepository = dashboardRepository
    
    dashboardRepository
      .$fiatData
      .receive(on: DispatchQueue.main)
      .sink { [weak self] fiatData in
        if fiatData.loading {
          self?.assets = fiatData.fiatAccount.map {
            AssetModel(
              id: $0.id,
              type: AssetType(rawValue: $0.currency.rawValue.uppercased()),
              availableBalance: $0.availableBalance,
              availableUsdBalance: $0.availableUsdBalance,
              externalAccountId: $0.externalAccountId
            )
          }
          if let account = fiatData.fiatAccount.first {
            self?.accountDataManager.fiatAccountID = account.id
            self?.accountDataManager.externalAccountID = account.externalAccountId
            self?.cashBalanceValue = account.availableBalance
            self?.selectedAsset = AssetType(rawValue: account.currency.rawValue.uppercased()) ?? .usd
            self?.firstLoadData(with: account.id)
          }
        }
        
        self?.isLoading = fiatData.loading
      }
      .store(in: &cancellable)
    
    subscribeLinkedSources()
    handleFundingAgreementData()
    handleEventReloadTransaction()
  }
  
  func subscribeLinkedSources() {
    accountDataManager.subscribeLinkedSourcesChanged { [weak self] entities in
      guard let self = self else { return }
      let linkedSources = entities.compactMap({ APILinkedSourceData(entity: $0) })
      self.linkedAccount = linkedSources
    }
    .store(in: &cancellable)
  }
  
  func handleEventReloadTransaction() {
    NotificationCenter.default.publisher(for: .moneyTransactionSuccess)
      .sink { [weak self] _ in
        guard let self else { return }
        guard let accountID = self.accountDataManager.fiatAccountID else { return }
        let animation = self.transactions.isEmpty ? true : false
        self.refreshTransaction(withAnimation: animation, accountID: accountID)
      }
      .store(in: &cancellable)
  }
  
  func onRefresh() {
    Task { @MainActor in
      _ = try? await dashboardRepository.getFiatAccounts()
      dashboardRepository.fetchNetspendLinkedSources()
      
      guard let accountID = accountDataManager.fiatAccountID else { return }
      guard activity != .loading else { return }
      refreshTransaction(withAnimation: true, accountID: accountID)
      NotificationCenter.default.post(name: .refreshListCards, object: nil)
    }
  }
  
  func firstLoadData(with accountID: String) {
    guard transactions.isEmpty || achInformation.accountName == ACHModel.default.accountName else { return }
    Task { @MainActor in
      do {
        activity = .loading
        try await loadTransactions(accountId: accountID)
        try await getACHInfo()
        activity = transactions.isEmpty ? .addFunds : .transactions
      } catch {
        activity = .addFunds
        log.error(error)
        toastMessage = error.userFriendlyMessage
      }
    }
  }
  
  func refreshTransaction(withAnimation: Bool, accountID: String) {
    Task { @MainActor in
      do {
        if withAnimation {
          activity = .loading
        }
        try await loadTransactions(accountId: accountID)
        if withAnimation {
          activity = transactions.isEmpty ? .addFunds : .transactions
        }
      } catch {
        if withAnimation {
          activity = .addFunds
        }
        log.error(error)
        toastMessage = error.userFriendlyMessage
      }
    }
  }
  
}

// MARK: - View Helpers
extension CashViewModel {
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
  
  func onClickedChangeAssetButton() {
    navigation = .changeAsset
  }
  
  func addMoneyTapped() {
    Haptic.impact(.light).generate()
    if linkedAccount.isEmpty {
      fullScreen = .fundCard(.receive)
    } else {
      navigation = .moveMoney(kind: .receive)
    }
  }
  
  func sendMoneyTapped() {
    Haptic.impact(.light).generate()
    if linkedAccount.isEmpty {
      fullScreen = .fundCard(.send)
    } else {
      navigation = .moveMoney(kind: .send)
    }
  }
  
  func transactionItemTapped(_ transaction: TransactionModel) {
    Haptic.impact(.light).generate()
    navigation = .transactionDetail(transaction)
  }
  
  func onClickedSeeAllButton() {
    navigation = .transactions
  }
  
  func guestCardTapped() {
    
  }
}

// MARK: - Private Functions
 extension CashViewModel {
  private func loadTransactions(accountId: String) async throws {
    let transactions = try await accountRepository.getTransactions(
      accountId: accountId,
      currencyType: currencyType,
      transactionTypes: Constants.TransactionTypesRequest.fiat.types,
      limit: transactionLimitEntity,
      offset: transactionLimitOffset
    )
    self.transactions = transactions.data.compactMap({ TransactionModel(from: $0) })
  }
  
  private func getACHInfo() async throws {
    do {
      achInformation = try await dashboardRepository.getACHInformation()
    } catch {
      log.error(error.userFriendlyMessage)
    }
  }
}

// MARK: - Types
extension CashViewModel {
  enum Activity {
    case loading
    case addFunds
    case transactions
  }
  
  enum Navigation {
    case changeAsset
    case transactions
    case transactionDetail(TransactionModel)
    case moveMoney(kind: MoveMoneyAccountViewModel.Kind)
    case agreement(APIAgreementData?)
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
