import Foundation
import LFSolidCard
import Factory
import NetSpendData
import NetspendDomain
import AccountDomain
import AccountData
import LFUtilities
import LFBaseBank
import LFSolidBank
import LFTransaction
import Combine
import BaseCard
import ExternalFundingData
import AccountService
import SolidDomain
import SolidData

@MainActor
final class CashViewModel: ObservableObject {
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.externalFundingDataManager) var externalFundingDataManager
  
  @Injected(\.solidAccountRepository) var solidAccountRepository
  @Injected(\.solidExternalFundingRepository) var solidExternalFundingRepository
  @Injected(\.fiatAccountService) var fiatAccountService
  
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
  @Published var achInformation: ACHModel = .default
  @Published var accountID: String = .empty
  @Published var fullScreen: FullScreen?
  @Published var linkedContacts: [LinkedSourceContact] = []
  
  lazy var solidGetWireTransfer: SolidGetWireTranferUseCaseProtocol = {
    SolidGetWireTranferUseCase(repository: solidExternalFundingRepository)
  }()
  
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
  
  let currencyType = Constants.CurrencyType.fiat.rawValue
  
  private let guestHandler: () -> Void
  private var subscriptions = Set<AnyCancellable>()
  
  init(guestHandler: @escaping () -> Void) {
    self.guestHandler = guestHandler
    firstLoadData()
    handleACHInfo()
    handleEventReloadTransaction()
    subscribeLinkedContacts()
  }
  
  func refreshable() {
    guard let accountID = accountDataManager.fiatAccountID else { return }
    refreshAccount()
    let animation = self.transactions.isEmpty ? true : false
    refreshTransaction(withAnimation: animation, accountID: accountID)
    NotificationCenter.default.post(name: .refreshListCards, object: nil)
  }
  
  private func subscribeLinkedContacts() {
    externalFundingDataManager.subscribeLinkedSourcesChanged({ [weak self] contacts in
      self?.linkedContacts = contacts.filter { $0.sourceType == .bank }
    })
    .store(in: &subscriptions)
  }
  
  private func handleEventReloadTransaction() {
    NotificationCenter.default.publisher(for: .moneyTransactionSuccess)
      .sink { [weak self] _ in
        guard let self else { return }
        guard let accountID = self.accountDataManager.fiatAccountID else { return }
        let animation = self.transactions.isEmpty ? true : false
        self.refreshTransaction(withAnimation: animation, accountID: accountID)
      }
      .store(in: &cancellable)
  }
  
  private func firstLoadData() {
    Task { @MainActor in
      do {
        activity = .loading
        isLoading = true
        if let account = try await refreshAccounts() {
          isLoading = false
          try await loadTransactions(accountId: account.id)
          activity = transactions.isEmpty ? .addFunds : .transactions
        }
      } catch {
        activity = .addFunds
        log.error(error)
      }
    }
  }
  
  func refreshAccount() {
    Task { @MainActor in
      do {
        defer { isLoading = false }
        isLoading = true
        try await refreshAccounts()
      } catch {
        log.error(error)
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
  
  func onClickedChangeAssetButton() {
    navigation = .changeAsset
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
  
  func transactionItemTapped(_ transaction: TransactionModel) {
    Haptic.impact(.light).generate()
    navigation = .transactionDetail(transaction)
  }
  
  func onClickedSeeAllButton() {
    navigation = .transactions
  }
  
  func guestCardTapped() {
    guestHandler()
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
  
  @discardableResult
  private func refreshAccounts() async throws -> AccountModel? {
    defer { isLoading = false }
    isLoading = true
    let accounts = try await getFiatAccounts()
    if let account = accounts.first {
      self.accountID = account.id
      self.accountDataManager.fiatAccountID = account.id
      self.accountDataManager.externalAccountID = account.externalAccountId
      self.cashBalanceValue = account.availableBalance
      self.selectedAsset = AssetType(rawValue: account.currency.rawValue.uppercased()) ?? .usd
    }
    return accounts.first
  }
  
  private func handleACHInfo() {
    Task {
      do {
        achInformation = try await getACHInformation()
      } catch {
        toastMessage = error.localizedDescription
      }
    }
  }
   
   private func getFiatAccounts() async throws -> [AccountModel] {
     var accounts = self.accountDataManager.fiatAccounts
     if accounts.isEmpty {
       accounts = try await fiatAccountService.getAccounts()
       self.accountDataManager.addOrUpdateAccounts(accounts)
     }
     return accounts
   }
   
   private func getACHInformation() async throws -> ACHModel {
     let account = try await getFiatAccounts().first
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
