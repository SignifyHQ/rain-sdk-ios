import Foundation
import LFCard
import Factory
import NetSpendData
import NetSpendDomain
import AccountDomain
import AccountData
import LFUtilities
import LFBank
import LFTransaction
import Combine
import BaseDashboard

@MainActor
final class CashViewModel: ObservableObject {
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.externalFundingRepository) var externalFundingRepository
  
  @Published var isCardActive: Bool = true
  @Published var isLoading: Bool = false
  @Published var isOpeningPlaidView: Bool = false
  @Published var isDisableView: Bool = false
  @Published var cashBalanceValue: Double = 0
  @Published var toastMessage: String?
  @Published var activity = Activity.loading
  @Published var cashCardDetails = CardModel.virtualDefault // MOCK DATA
  @Published var selectedAsset: AssetType = .usd
  @Published var navigation: Navigation?
  @Published var transactions: [TransactionModel] = []
  @Published var assets: [AssetModel] = []
  @Published var linkedAccount: [APILinkedSourceData] = []
  @Published var achInformation: ACHModel = .default
  @Published var fullScreen: FullScreen?
  
  let currencyType = Constants.CurrencyType.fiat.rawValue
  
  //This is flag handle case when app have change scenePhase
  var shouldReloadListTransaction: Bool = false
  
  var transactionLimitEntity: Int {
    100
  }
  
  var transactionLimitOffset: Int {
    0
  }

  private(set) var addFundsViewModel = AddFundsViewModel()
  
  private var cancellable: Set<AnyCancellable> = []
  
  init(
    accounts: (
      accountsFiat: Published<[LFAccount]>.Publisher,
      isLoading: Published<Bool>.Publisher
    ),
    linkedAccount: Published<[APILinkedSourceData]>.Publisher
  ) {
    
    accounts.accountsFiat
      .receive(on: DispatchQueue.main)
      .sink { [weak self] accounts in
        self?.assets = accounts.map {
          AssetModel(
            id: $0.id,
            type: AssetType(rawValue: $0.currency.uppercased()),
            availableBalance: $0.availableBalance,
            availableUsdBalance: $0.availableUsdBalance,
            externalAccountId: $0.externalAccountId
          )
        }
        if let account = accounts.first { // TODO: Temp Just get one
          self?.accountDataManager.fiatAccountID = account.id
          self?.accountDataManager.externalAccountID = account.externalAccountId
          self?.cashBalanceValue = account.availableBalance
          self?.selectedAsset = AssetType(rawValue: account.currency) ?? .usd
          self?.firstLoadData(with: account.id)
        }
      }
      .store(in: &cancellable)
    
    accounts.isLoading
      .assign(to: \.isLoading, on: self)
      .store(in: &cancellable)
    
    linkedAccount
      .assign(to: \.linkedAccount, on: self)
      .store(in: &cancellable)
    
    handleFundingAgreementData()
    handleEventReloadTransaction()
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
    guard let accountID = accountDataManager.fiatAccountID else { return }
    guard activity != .loading else { return }
    refreshTransaction(withAnimation: false, accountID: accountID)
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
        toastMessage = error.localizedDescription
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
        toastMessage = error.localizedDescription
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
      navigation = .addMoney
    }
  }
  
  func sendMoneyTapped() {
    Haptic.impact(.light).generate()
    if linkedAccount.isEmpty {
      fullScreen = .fundCard(.send)
    } else {
      navigation = .sendMoney
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
      let achResponse = try await externalFundingRepository.getACHInfo(sessionID: accountDataManager.sessionID)
      achInformation = ACHModel(
        accountNumber: achResponse.accountNumber ?? Constants.Default.undefined.rawValue,
        routingNumber: achResponse.routingNumber ?? Constants.Default.undefined.rawValue,
        accountName: achResponse.accountName ?? Constants.Default.undefined.rawValue
      )
    } catch {
      log.error(error.localizedDescription)
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
    case bankStatements
    case changeAsset
    case transactions
    case transactionDetail(TransactionModel)
    case addMoney
    case sendMoney
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
