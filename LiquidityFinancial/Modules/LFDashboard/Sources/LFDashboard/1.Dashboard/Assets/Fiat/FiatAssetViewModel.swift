import Foundation
import AccountDomain
import AccountData
import NetSpendData
import LFUtilities
import Factory
import LFBank
import LFTransaction
import BaseDashboard
import Combine

@MainActor
class FiatAssetViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.externalFundingRepository) var externalFundingRepository
  
  @Published var asset: AssetModel
  @Published var isLoadingACH: Bool = false
  @Published var isDisableView: Bool = false
  @Published var showTransferSheet: Bool = false
  @Published var cryptoPrice: String = "0.00"
  @Published var changePercent: Double = 0
  @Published var showCryptoDetail: Bool = false
  @Published var toastMessage: String = ""
  @Published var navigation: Navigation?
  @Published var activity = Activity.loading
  @Published var transactions: [TransactionModel] = []
  @Published var achInformation: ACHModel = .default
  @Published var linkedAccount: [APILinkedSourceData] = []
  @Published var fullScreen: FullScreen?
  
  let currencyType = Constants.CurrencyType.fiat.rawValue
  private var cancellable: Set<AnyCancellable> = []

  var usdBalance: String {
    asset.availableBalanceFormatted
  }
  
  var title: String {
    asset.type?.title ?? .empty
  }
  
  init(asset: AssetModel) {
    self.asset = asset
    getACHInfo()
    subscribeLinkedAccounts()
    subscribeAssetChange(id: asset.id)
  }
}

// MARK: - Private Functions
private extension FiatAssetViewModel {
  func getAccountDetail(id: String) async {
    do {
      let account = try await accountRepository.getAccountDetail(id: id)
      self.accountDataManager.fiatAccountID = account.id
      self.accountDataManager.addOrUpdateAccount(account)
    } catch {
      toastMessage = error.localizedDescription
    }
  }
  
  func loadTransactions(accountId: String) async {
    do {
      let transactions = try await accountRepository.getTransactions(
        accountId: accountId,
        currencyType: currencyType,
        transactionTypes: Constants.TransactionTypesRequest.fiat.types,
        limit: 50,
        offset: 0
      )
      let transactionsModel = transactions.data.compactMap({ TransactionModel(from: $0) })
      if transactionsModel.isEmpty {
        activity = .addFund
      } else {
        self.transactions = transactionsModel
        activity = .transactions
      }
    } catch {
      toastMessage = error.localizedDescription
      activity = .failure
    }
  }
  
  func getACHInfo() {
    isLoadingACH = true
    Task {
      do {
        let achResponse = try await externalFundingRepository.getACHInfo(sessionID: accountDataManager.sessionID)
        achInformation = ACHModel(
          accountNumber: achResponse.accountNumber ?? Constants.Default.undefined.rawValue,
          routingNumber: achResponse.routingNumber ?? Constants.Default.undefined.rawValue,
          accountName: achResponse.accountName ?? Constants.Default.undefined.rawValue
        )
        isLoadingACH = false
      } catch {
        isLoadingACH = false
        toastMessage = error.localizedDescription
      }
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
  
  func subscribeAssetChange(id: String) {
    accountDataManager
      .accountsSubject
      .receive(on: DispatchQueue.main)
      .compactMap({ (accounts: [LFAccount]) -> AssetModel? in
      guard let account = accounts.first(where: {
        $0.id == id
      }) else {
        return nil
      }
      return AssetModel(account: account)
    })
    .assign(to: \.asset, on: self)
    .store(in: &cancellable)
  }
}

// MARK: - View Helpers
extension FiatAssetViewModel {
  func refreshData() {
    Task {
      await refresh()
    }
  }
  
  func refresh() async {
    let id = self.asset.id
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
}

// MARK: - Types
extension FiatAssetViewModel {
  enum Activity {
    case loading
    case failure
    case addFund
    case transactions
  }
  
  enum Navigation {
    case addMoney
    case sendMoney
    case transactions
    case transactionDetail(TransactionModel)
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
