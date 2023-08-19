import Foundation
import AccountDomain
import LFUtilities
import Factory
import LFTransaction

@MainActor
class CryptoAssetViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.accountRepository) var accountRepository
  
  @Published var account: LFAccount?
  @Published var loading: Bool = false
  @Published var showTransferSheet: Bool = false
  @Published var cryptoPrice: String = "0.00"
  @Published var changePercent: Double = 0
  @Published var showCryptoDetail: Bool = false
  @Published var toastMessage: String = ""
  @Published var isLoading: Bool = false
  @Published var navigation: Navigation?
  @Published var sheet: SheetPresentation?
  @Published var activity = Activity.loading
  @Published var transactions: [TransactionModel] = []
  
  let asset: AssetModel
  let currencyType = Constants.CurrencyType.crypto.rawValue
  private let guestHandler: () -> Void

  var cryptoBalance: String {
    account?.availableBalance.formattedAmount(
      minFractionDigits: 3, maxFractionDigits: 3
    ) ?? asset.availableBalanceFormatted
  }
  
  var usdBalance: String {
    account?.availableUsdBalance.formattedAmount(
      prefix: Constants.CurrencyUnit.usd.symbol, minFractionDigits: 2
    ) ?? asset.availableUsdBalanceFormatted ?? .empty
  }
  
  var isPositivePrice: Bool {
    changePercent > 0
  }

  var changePercentAbsString: String {
    String(format: "%.2f%%", abs(changePercent))
  }
  
  init(asset: AssetModel, guestHandler: @escaping () -> Void) {
    self.asset = asset
    self.guestHandler = guestHandler
  }
}

// MARK: - Private Functions
private extension CryptoAssetViewModel {
  func getCryptoAccount() async {
    do {
      let accounts = try await accountRepository.getAccount(currencyType: currencyType)
      guard let account = accounts.first else {
        return
      }
      self.account = account
      await loadTransactions(accountId: account.id)
    } catch {
      toastMessage = error.localizedDescription
    }
  }
  
  func loadTransactions(accountId: String) async {
    do {
      let transactions = try await accountRepository.getTransactions(
        accountId: accountId,
        currencyType: currencyType,
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
extension CryptoAssetViewModel {
  func refreshData() {
    Task {
      await getCryptoAccount()
    }
  }
  
  func onClickedSeeAllButton() {
    navigation = .transactions
  }
  
  func onClickedBuyButton() {
    Haptic.impact(.light).generate()
    navigation = .buyCrypto
  }
  
  func onClickedSellButton() {
    Haptic.impact(.light).generate()
    navigation = .sellCrypto
  }
  
  func transferButtonTapped() {
    Haptic.impact(.light).generate()
    showTransferSheet = true
  }
  
  func receiveButtonTapped() {
    showTransferSheet = false
    navigation = .receiveCrypto
  }
  
  func sendButtonTapped() {
    showTransferSheet = false
    navigation = .sendCrypto
  }

  func walletRowTapped() {
    Haptic.impact(.soft).generate()
    if false { // userManager.isGuest TODO: - Will be updated later
      guestHandler()
    } else {
      sheet = .wallet
    }
  }
  
  func transactionItemTapped(_ transaction: TransactionModel) {
    if false { // userManager.isGuest TODO: Will be implemented later
      guestHandler()
    } else {
      Haptic.impact(.light).generate()
      navigation = .transactionDetail(transaction)
    }
  }
}

extension CryptoAssetViewModel {
  enum Activity {
    case loading
    case failure
    case transactions
  }
  
  enum Navigation {
    case buyCrypto
    case sellCrypto
    case receiveCrypto
    case sendCrypto
    case transactions
    case transactionDetail(TransactionModel)
  }
  
  enum SheetPresentation: Identifiable {
    case wallet
    
    var id: String {
      switch self {
      case .wallet: return "wallet"
      }
    }
  }
}
