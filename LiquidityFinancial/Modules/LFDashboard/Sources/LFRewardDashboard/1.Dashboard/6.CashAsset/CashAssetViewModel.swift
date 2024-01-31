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

@MainActor
class CashAssetViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.externalFundingRepository) var externalFundingRepository
  @LazyInjected(\.fiatAccountService) var fiatAccountService
  @LazyInjected(\.solidExternalFundingRepository) var solidExternalFundingRepository
  
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
  @Published var linkedAccount: [APILinkedSourceData] = []
  @Published var fullScreen: FullScreen?
  @Published var isLoadingACH: Bool = false
  @Published var achInformation: ACHModel = .default
  
  let currencyType = Constants.CurrencyType.fiat.rawValue
  
  private(set) var addFundsViewModel = AddFundsViewModel()
  private var cancellable: Set<AnyCancellable> = []
  
  lazy var solidGetWireTransfer: SolidGetWireTranferUseCaseProtocol = {
    SolidGetWireTranferUseCase(repository: solidExternalFundingRepository)
  }()

  var usdBalance: String {
    assetModel?.availableBalanceFormatted ?? .empty
  }
  
  var title: String {
    assetModel?.type?.title ?? .empty
  }
  
  init() {
    subscribeLinkedAccounts()
    subscribeAssetChange()
    handleACHData()
  }
}

// MARK: - Private Functions
private extension CashAssetViewModel {
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
  
  func subscribeAssetChange() {
    accountDataManager
      .accountsSubject
      .receive(on: DispatchQueue.main)
      .compactMap({ (accounts: [AccountModel]) -> AssetModel? in
        guard let model = accounts.first(where: { model in
          model.currency == .USD
        }) else {
          return nil
        }
        return AssetModel(account: model)
      })
    .assign(to: \.assetModel, on: self)
    .store(in: &cancellable)
  }
  
}

// MARK: - View Helpers
extension CashAssetViewModel {
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
    }
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
