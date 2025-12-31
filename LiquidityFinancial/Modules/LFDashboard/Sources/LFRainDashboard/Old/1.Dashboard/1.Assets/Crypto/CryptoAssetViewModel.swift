import Combine
import SwiftUI
import Foundation
import AccountDomain
import AccountData
import LFUtilities
import Factory
import CryptoChartData
import GeneralFeature
import Services
import AccountService

@MainActor
class CryptoAssetViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.marketManager) var marketManager
  @LazyInjected(\.analyticsService) var analyticsService

  @Published var loading: Bool = false
  @Published var showTransferSheet: Bool = false
  @Published var cryptoPrice: String = "0.00"
  @Published var closePrice: Double?
  @Published var changePercent: Double = 0
  @Published var showCryptoDetail: Bool = false
  @Published var toastMessage: String = ""
  @Published var isLoading: Bool = false
  @Published var navigation: Navigation?
  @Published var sheet: SheetPresentation?
  @Published var activity = Activity.loading
  @Published var transactions: [TransactionModel] = []
  @Published var asset: AssetModel
  
  let currencyType = Constants.CurrencyType.crypto.rawValue
  private var subscribers: Set<AnyCancellable> = []
  
  var filterOptionSubject = CurrentValueSubject<CryptoFilterOption, Never>(.live)
  var chartOptionSubject = CurrentValueSubject<ChartOption, Never>(.line)
  
  private lazy var getTransactionsListUseCase: GetTransactionsListUseCaseProtocol = {
    GetTransactionsListUseCase(repository: accountRepository)
  }()
  
  var cryptoIconImage: Image? {
    asset.type?.icon
  }
  
  var cryptoBalance: String {
    asset.availableBalanceFormatted
  }
  
  var usdBalance: String {
    asset.totalUsdBalanceFormatted ?? .empty
  }
  
  var fluctuationAmmount: String {
    guard let closePrice = closePrice else {
      return .empty
    }
    let value = closePrice * asset.availableBalance - (asset.availableUsdBalance ?? 0)
    return "(\(value.formattedUSDAmount()))"
  }
  
  var isPositivePrice: Bool {
    changePercent > 0
  }

  var changePercentAbsString: String {
    String(format: "%.2f%%", abs(changePercent))
  }
  
  init(asset: AssetModel) {
    self.asset = asset
    
    observeMarketManager()
    observeAssetChange(id: asset.id)
    requestMarketData()
  }
}

// MARK: - Private Functions
private extension CryptoAssetViewModel {
  func requestMarketData() {
    guard let type = asset.type else {
      return
    }
    marketManager.clearData()
    Task {
      try? await marketManager.fetchData(cryptoCurrency: type.rawValue)
    }
  }
  
  func loadTransactions() async {
    do {
      let parameters = APITransactionsParameters(
        currencyType: currencyType,
        transactionTypes: Constants.TransactionTypesRequest.crypto.types,
        limit: Constants.shortTransactionLimit,
        offset: Constants.transactionOffset,
        contractAddress: asset.id
      )
      let transactions = try await getTransactionsListUseCase.execute(parameters: parameters)
      self.transactions = transactions.data.compactMap({ TransactionModel(from: $0) })
      activity = .transactions
    } catch {
      toastMessage = error.userFriendlyMessage
      activity = .failure
    }
  }
  
  func observeAssetChange(id: String) {
    accountDataManager.accountsSubject
      .receive(on: DispatchQueue.main)
      .compactMap({ (accounts: [AccountModel]) -> AssetModel? in
      guard let account = accounts.first(where: {
        $0.id == id
      }) else {
        return nil
      }
      return AssetModel(account: account)
    })
    .assign(to: \.asset, on: self)
    .store(in: &subscribers)
  }
  
  func observeMarketManager() {
    marketManager.liveLineModelsSubject.map { models in
      guard let value = models.last?.value else {
        return "0.00"
      }
      return value.formattedAmount(
        prefix: Constants.CurrencyUnit.usd.symbol,
        minFractionDigits: 6,
        maxFractionDigits: 6
      )
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
    
    marketManager.liveLineModelsSubject.map { models in
      guard let value = models.last?.close else {
        return nil
      }
      return value
    }
    .receive(on: DispatchQueue.main)
    .assign(to: \.closePrice, on: self)
    .store(in: &subscribers)
  }
}

// MARK: - View Helpers
extension CryptoAssetViewModel {
  func refreshData() {
    Task {
      await refresh()
    }
  }
  
  func refresh() async {
    await withTaskGroup(of: Void.self) { group in
      group.addTask {
        await self.loadTransactions()
      }
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
    analyticsService.track(event: AnalyticsEvent(name: .tapsTransferCrypto))
    Haptic.impact(.light).generate()
    showTransferSheet = true
  }
  
  func receiveButtonTapped() {
    analyticsService.track(event: AnalyticsEvent(name: .tapsRecieveCrypto))
    showTransferSheet = false
    navigation = .receiveCrypto
  }
  
  func sendButtonTapped() {
    analyticsService.track(event: AnalyticsEvent(name: .tapsSendCrypto))
    showTransferSheet = false
    navigation = .sendCrypto
  }

  func walletRowTapped() {
    analyticsService.track(event: AnalyticsEvent(name: .tapsSendToExternalWallet))
    Haptic.impact(.soft).generate()
    sheet = .wallet
  }
  
  func cryptoChartTapped() {
    Haptic.impact(.soft).generate()
    navigation = .chartDetail
  }
  
  func transactionItemTapped(_ transaction: TransactionModel) {
    Haptic.impact(.light).generate()
    navigation = .transactionDetail(transaction)
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
