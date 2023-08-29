import Combine
import Foundation
import AccountDomain
import LFUtilities
import Factory
import LFTransaction
import CryptoChartData
import LFCryptoChart

@MainActor
class CryptoAssetViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.marketManager) var marketManager

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
  private var subscribers: Set<AnyCancellable> = []
  private var isGuest = false // TODO: - Will be remove after handle guest feature
  
  var filterOptionSubject = CurrentValueSubject<CryptoFilterOption, Never>(.live)
  var chartOptionSubject = CurrentValueSubject<ChartOption, Never>(.line)
  
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
    
    observeMarketManager()
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
      self.accountDataManager.cryptoAccountID = account.id
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
        transactionTypes: Constants.TransactionTypesRequest.crypto.types,
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
  
  func observeMarketManager() {
    marketManager.liveLineModelsSubject.map { models in
      guard let value = models.last?.close else {
        return "0.00"
      }
      return value.formattedAmount(prefix: "$", minFractionDigits: 6, maxFractionDigits: 6)
    }
    .receive(on: DispatchQueue.main)
    .assign(to: \.cryptoPrice, on: self)
    .store(in: &subscribers)
    
    marketManager.liveLineModelsSubject.map { models -> Double in
      guard let value = models.last?.changePercentage else {
        return 0
      }
      return value
    }
    .receive(on: DispatchQueue.main)
    .assign(to: \.changePercent, on: self)
    .store(in: &subscribers)
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
    if isGuest {
      guestHandler()
    } else {
      sheet = .wallet
    }
  }
  
  func cryptoChartTapped() {
    Haptic.impact(.soft).generate()
    navigation = .chartDetail
  }
  
  func transactionItemTapped(_ transaction: TransactionModel) {
    if isGuest {
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
    case chartDetail
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
