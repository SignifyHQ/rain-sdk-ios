import Foundation
import AccountDomain
import LFUtilities
import Factory
import LFTransaction
import Combine
import BaseDashboard

@MainActor
class RewardTabViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.accountRepository) var accountRepository
  
  @Published var account: LFAccount?
  @Published var assetModel: AssetModel?
  @Published var toastMessage: String = ""
  @Published var isLoading: Bool = false
  @Published var navigation: Navigation?
  @Published var activity = Activity.loading
  @Published var transactions: [TransactionModel] = []
  
  let currencyType = Constants.CurrencyType.crypto.rawValue
  
  private var cancellable: Set<AnyCancellable> = []
  
  init(accounts: (accountsCrypto: Published<[LFAccount]>.Publisher, isLoading: Published<Bool>.Publisher)) {
    accounts.accountsCrypto
      .receive(on: DispatchQueue.main)
      .sink { [weak self] accounts in
        if let account = accounts.first {
          self?.account = account
          self?.assetModel = AssetModel(
            id: account.id,
            type: AssetType(rawValue: account.currency),
            availableBalance: account.availableBalance,
            availableUsdBalance: account.availableUsdBalance,
            externalAccountId: account.externalAccountId
          )
          self?.accountDataManager.cryptoAccountID = account.id
          self?.fetchAllTransactions()
        }
      }
      .store(in: &cancellable)
    
    accounts.isLoading
      .assign(to: \.isLoading, on: self)
      .store(in: &cancellable)
  }
}

// MARK: - View Helpers
extension RewardTabViewModel {
  func fetchAllTransactions() {
    Task { @MainActor in
      defer { isLoading = false }
      isLoading = true
      await apiLoadTransactions()
    }
  }
  
  func apiLoadTransactions() async {
    if let account = account {
      do {
        let transactions = try await accountRepository.getTransactions(
          accountId: account.id,
          currencyType: currencyType,
          transactionTypes: Constants.TransactionTypesRequest.rewardCryptoBack.types,
          limit: 50,
          offset: 0
        )
        self.transactions = transactions.data.compactMap({ TransactionModel(from: $0) })
        activity = .transactions
      } catch {
        toastMessage = error.localizedDescription
        if transactions.isEmpty {
          activity = .failure
        }
      }
    }
  }
  
  func onClickedChangeReward() {
    guard let assetModel = assetModel else {
      return
    }
    navigation = .changeReward(assetModels: [assetModel], selectedAssetModel: assetModel)
  }
  
  func onClickedSeeAllButton() {
    navigation = .transactions
  }
  
  func transactionItemTapped(_ transaction: TransactionModel) {
    Haptic.impact(.light).generate()
    navigation = .transactionDetail(transaction)
  }
}

extension RewardTabViewModel {
  enum Activity {
    case loading
    case failure
    case transactions
  }
  
  enum Navigation {
    case changeReward(assetModels: [AssetModel], selectedAssetModel: AssetModel)
    case transactions
    case transactionDetail(TransactionModel)
  }
}
