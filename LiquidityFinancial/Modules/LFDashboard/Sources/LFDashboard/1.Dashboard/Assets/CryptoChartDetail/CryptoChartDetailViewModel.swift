import Combine
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
  
  let account: LFAccount?
  let selectedHistoricalPriceSubject = CurrentValueSubject<HistoricalPriceModel?, Never>(nil)
  
  private var subscribers: Set<AnyCancellable> = []
  
  var isPositivePrice: Bool {
    changePercent > 0
  }
  
  var changePercentAbsString: String {
    String(format: "%.2f%%", abs(changePercent))
  }
  
  init(account: LFAccount?) {
    self.account = account
    observeMarketManager()
    subscribeToUserTransactionNotifications()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  func appearOperations() {
      // TODO: - Will be implemented later
      // analyticsService.track(event: Event(name: EventName.viewCryptoWalletSetup))
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
      return value.formattedAmount(prefix: "$", minFractionDigits: 6, maxFractionDigits: 6)
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
    
    selectedHistoricalPriceSubject
      .receive(on: DispatchQueue.main)
      .sink(receiveValue: { [weak self] model in
        guard let self = self else {
          return
        }
        guard let model = model,
              let open = model.open,
              let close = model.open,
              let high = model.high,
              let low = model.low else {
          self.openPrice = ""
          self.closePrice = ""
          self.highPrice = ""
          self.lowPrice = ""
          self.volumePrice = ""
          return
        }
        self.openPrice = open.formattedAmount(minFractionDigits: 6, maxFractionDigits: 6)
        self.closePrice = close.formattedAmount(minFractionDigits: 6, maxFractionDigits: 6)
        self.highPrice = high.formattedAmount(minFractionDigits: 6, maxFractionDigits: 6)
        self.lowPrice = low.formattedAmount(minFractionDigits: 6, maxFractionDigits: 6)
        self.volumePrice = model.volume?.formattedAmount(minFractionDigits: 6, maxFractionDigits: 6) ?? "-"
      })
      .store(in: &subscribers)
  }
}

  // MARK: - Actions
extension CryptoChartDetailViewModel {
  func buyButtonTapped() {
      // TODO: - Will be implemented later
      // analyticsService.track(event: Event(name: EventName.tapsBuyCrypto))
    Haptic.impact(.light).generate()
    navigation = .buy
  }
  
  func sellButtonTapped() {
      // TODO: - Will be implemented later
      // analyticsService.track(event: Event(name: EventName.tapsSellCrypto))
    Haptic.impact(.light).generate()
    navigation = .sell
  }
  
  func transferButtonTapped() {
      // TODO: - Will be implemented later
      // analyticsService.track(event: Event(name: .tapsTransferCrypto))
    Haptic.impact(.light).generate()
    showTransferSheet = true
  }
  
  func sendButtonTapped() {
      // TODO: - Will be implemented later
      // analyticsService.track(event: Event(name: EventName.tapsSendCrypto.rawValue))
    showTransferSheet = false
    if let cryptoBalance = account?.availableBalance, cryptoBalance > 0 {
      navigation = .send
    } else {
      popup = .sendBalance
    }
  }
  
  func receiveButtonTapped() {
    showTransferSheet = false
      // TODO: - Will be implemented later
      // analyticsService.track(event: Event(name: EventName.tapsRecieveCrypto.rawValue))
    navigation = .receive
  }
  
  func hideCrytoTransferSheet() {
    showTransferSheet = false
  }
  
  func walletRowTapped() {}
  
  func clearPopup() {
    popup = nil
  }
  
  func seeAllTransactionsTapped() {
    navigation = .transactions
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
    case accountsView
    case transactions
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
