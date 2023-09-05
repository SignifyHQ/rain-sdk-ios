import Combine
import BaseDashboard
import SwiftUI
import LFUtilities
import LFTransaction
import CryptoChartData
import Factory
import AccountDomain

@MainActor
final class CryptoChartDetailViewModel: ObservableObject {
  @LazyInjected(\.marketManager) var marketManager
  @LazyInjected(\.accountDataManager) var accountDataManager
  
  @Published var loading: Bool = false
  @Published var showTransferSheet: Bool = false
  @Published var navigation: Navigation?
  @Published var popup: Popup?
  @Published var activity = Activity.failure
  @Published var sheet: SheetPresentation?
  
  @Published var cryptoPrice: String = "0.0"
  @Published var changePercent: Double = 0
  
  @Published var openPrice: String = ""
  @Published var closePrice: String = ""
  @Published var highPrice: String = ""
  @Published var lowPrice: String = ""
  @Published var volumePrice: String = ""
  
  let asset: AssetModel
  let selectedHistoricalPriceSubject = CurrentValueSubject<HistoricalPriceModel?, Never>(nil)
  
  private var subscribers: Set<AnyCancellable> = []
  
  var isPositivePrice: Bool {
    changePercent > 0
  }
  
  var changePercentAbsString: String {
    String(format: "%.2f%%", abs(changePercent))
  }
  
  init(asset: AssetModel) {
    self.asset = asset
    observeMarketManager()
    subscribeToUserTransactionNotifications()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  func appearOperations() {
    Task {
      await refresh(includeAccounts: false)
    }
  }
  
  func refresh(includeAccounts: Bool = true) async {
      // TODO: - Will be implemented later
  }
  
  private func subscribeToUserTransactionNotifications() {
      // TODO: - Will be implemented later
  }
  
  private func observeMarketManager() {
    marketManager.liveLineModelsSubject.map { models in
      guard let value = models.last?.close else {
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
      return Double(value)
    }
    .receive(on: DispatchQueue.main)
    .assign(to: \.changePercent, on: self)
    .store(in: &subscribers)
    
    marketManager.liveLineModelsSubject
      .receive(on: DispatchQueue.main)
      .sink(receiveValue: { [weak self] models in
        guard let self = self, let model = models.last else {
          return
        }
        if self.selectedHistoricalPriceSubject.value == nil {
          self.receiveSocketPriceValue(model: model)
        }
      })
      .store(in: &subscribers)
    
    selectedHistoricalPriceSubject
      .receive(on: DispatchQueue.main)
      .sink(receiveValue: { [weak self] model in
        guard let model = model else {
          return
        }
        self?.receiveSocketPriceValue(model: model)
      })
      .store(in: &subscribers)
  }
  
  private func receiveSocketPriceValue(model: HistoricalPriceModel) {
    guard let open = model.open,
          let close = model.open,
          let high = model.high,
          let low = model.low else {
      return
    }
    openPrice = open.formattedAmount(
      prefix: Constants.CurrencyUnit.usd.symbol,
      minFractionDigits: 6,
      maxFractionDigits: 6
    )
    closePrice = close.formattedAmount(
      prefix: Constants.CurrencyUnit.usd.symbol,
      minFractionDigits: 6,
      maxFractionDigits: 6
    )
    highPrice = high.formattedAmount(
      prefix: Constants.CurrencyUnit.usd.symbol,
      minFractionDigits: 6,
      maxFractionDigits: 6
    )
    lowPrice = low.formattedAmount(
      prefix: Constants.CurrencyUnit.usd.symbol,
      minFractionDigits: 6,
      maxFractionDigits: 6
    )
    volumePrice = model.volume?.formattedAmount(
      prefix: Constants.CurrencyUnit.usd.symbol,
      minFractionDigits: 2,
      maxFractionDigits: 2
    ) ?? "-"
  }
}

  // MARK: - Actions
extension CryptoChartDetailViewModel {
  func buyButtonTapped() {
    Haptic.impact(.light).generate()
    navigation = .buy
  }
  
  func sellButtonTapped() {
    Haptic.impact(.light).generate()
    navigation = .sell
  }
  
  func transferButtonTapped() {
    Haptic.impact(.light).generate()
    showTransferSheet = true
  }
  
  func sendButtonTapped() {
    showTransferSheet = false
    if asset.availableBalance > 0 {
      navigation = .send
    } else {
      popup = .sendBalance
    }
  }
  
  func receiveButtonTapped() {
    showTransferSheet = false
    navigation = .receive
  }
  
  func hideCrytoTransferSheet() {
    showTransferSheet = false
  }
  
  func walletRowTapped() {}
  
  func clearPopup() {
    popup = nil
  }
}

  // MARK: - Types
extension CryptoChartDetailViewModel {
  enum Activity {
    case loading
    case failure
  }
  
  enum Navigation {
    case addMoney
    case send
    case receive
    case buy
    case sell
  }
  
  enum SheetPresentation: Identifiable {
    case trxDetail(TransactionModel)
    case wallet
    
    var id: String {
      switch self {
      case .trxDetail: return "trxDetail"
      case .wallet: return "wallet"
      }
    }
  }
  
  enum Popup {
    case sendBalance
  }
}
