import Foundation
import AccountDomain
import LFUtilities
import Factory
import LFTransaction

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
  
  init() {
  }
}

// MARK: - Private Functions
private extension RewardTabViewModel {
  func getCryptoAccount() async {
    do {
      let accounts = try await accountRepository.getAccount(currencyType: currencyType)
      guard let account = accounts.first else {
        return
      }
      self.account = account
      self.assetModel = AssetModel(
        type: AssetType(rawValue: account.currency),
        availableBalance: account.availableBalance,
        availableUsdBalance: account.availableUsdBalance
      )
      self.accountDataManager.cryptoAccountID = account.id
    } catch {
      toastMessage = error.localizedDescription
    }
  }
  
  func loadTransactions(accountId: String) async {
    do {
      let transactions = try await accountRepository.getTransactions(
        accountId: accountId,
        currencyType: currencyType,
        transactionTypes: Constants.TransactionTypesRequest.rewardCryptoBack.types,
        limit: 50,
        offset: 0
      )
      self.transactions = transactions.data.compactMap({ TransactionModel(from: $0) })
      activity = .transactions
    } catch {
      toastMessage = error.localizedDescription
      activity = .failure
    }
  }
}

// MARK: - View Helpers
extension RewardTabViewModel {
  func refreshData() {
    Task {
      defer { isLoading = false }
      isLoading = true
      await getCryptoAccount()
      
      if let account = account {
        await loadTransactions(accountId: account.id)
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
