import Foundation
import Factory
import ZerohashData
import ZerohashDomain
import BiometricsManager
import AccountData
import Combine
import LFLocalizable
import LFUtilities
import LFStyleGuide
import SwiftUI
import Services

@MainActor
class ConfirmBuySellCryptoViewModel: ObservableObject {
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.zerohashRepository) var zerohashRepository
  @LazyInjected(\.biometricsManager) var biometricsManager
  @LazyInjected(\.cryptoAccountService) var cryptoAccountService
  @LazyInjected(\.analyticsService) var analyticsService
  
  @Published var showIndicator: Bool = false
  @Published var toastMessage: String?
  @Published var navigation: Navigation?
  
  private lazy var sellCryptoUseCase: SellCryptoUseCaseProtocol = {
    return SellCryptoUseCase(repository: zerohashRepository)
  }()
  
  private lazy var buyCryptoUseCase: BuyCryptoUseCaseProtocol = {
    return BuyCryptoUseCase(repository: zerohashRepository)
  }()
  
  private var cancellables: Set<AnyCancellable> = []

  let type: Kind
  
  init(type: Kind) {
    self.type = type
  }
  
  var title: String {
    switch type {
    case let .buyCrypto(quote, _):
      return LFLocalizable.ConfirmBuySellCrypto.Buy.title(total(of: quote.quantity, price: quote.price))
    case let .sellCrypto(quote, _):
      return LFLocalizable.ConfirmBuySellCrypto.Sell.title(total(of: quote.quantity, price: quote.price))
    }
  }
  
  var details: [RowDetail] {
    switch type {
    case let .buyCrypto(quote, _):
      return [
        .init(title: LFLocalizable.ConfirmBuySellCrypto.OrderType.title, value: LFLocalizable.ConfirmBuySellCrypto.Buy.text),
        .init(title: LFLocalizable.ConfirmBuySellCrypto.Amount.title, value: LFLocalizable.ConfirmBuySellCrypto.Amount.valueCrypto(quote.quantity ?? 0.0)),
        .init(title: LFLocalizable.ConfirmBuySellCrypto.ExchangeRate.title, value: LFLocalizable.ConfirmBuySellCrypto.Price.value(quote.price?.formattedAmount(minFractionDigits: 2, maxFractionDigits: 6) ?? "")),
        .init(title: LFLocalizable.ConfirmBuySellCrypto.Symbol.title, value: quote.cryptoCurrency ?? ""),
        .init(title: LFLocalizable.ConfirmBuySellCrypto.Fee.title, value: "$0"),
        .init(title: LFLocalizable.ConfirmBuySellCrypto.Total.title, value: LFLocalizable.ConfirmBuySellCrypto.Total.value(total(of: quote.quantity, price: quote.price)))
      ]
    case let .sellCrypto(quote, _):
      return [
        .init(title: LFLocalizable.ConfirmBuySellCrypto.OrderType.title, value: LFLocalizable.ConfirmBuySellCrypto.Sell.text),
        .init(title: LFLocalizable.ConfirmBuySellCrypto.Amount.title, value: LFLocalizable.ConfirmBuySellCrypto.Amount.valueCrypto(quote.quantity ?? 0.0)),
        .init(title: LFLocalizable.ConfirmBuySellCrypto.ExchangeRate.title, value: LFLocalizable.ConfirmBuySellCrypto.Price.value(quote.price?.formattedAmount(minFractionDigits: 2, maxFractionDigits: 6) ?? "")),
        .init(title: LFLocalizable.ConfirmBuySellCrypto.Symbol.title, value: quote.cryptoCurrency ?? ""),
        .init(title: LFLocalizable.ConfirmBuySellCrypto.Fee.title, value: "$0"),
        .init(title: LFLocalizable.ConfirmBuySellCrypto.Total.title, value: LFLocalizable.ConfirmBuySellCrypto.Total.value(total(of: quote.quantity, price: quote.price)))
      ]
    }
  }
  
  var disclosure: String {
    LFLocalizable.ConfirmBuySellCrypto.Disclosure.crypto
  }
  
  func total(of quantity: Double?, price: Double?) -> String {
    let fee: Double = 0 //default set in local always is = 0
    let quantity = quantity ?? 0
    let price = price ?? 0
    let total = quantity * price + fee
    return total.formattedAmount(prefix: "$")
  }
  
  func confirmButtonClicked() {
    switch type {
    case .buyCrypto(let quote, let accountID):
      analyticsService.track(event: AnalyticsEvent(name: .tapsConfirmBuy))
      callBioMetric {
        self.apiBuyCrypto(accountId: accountID, quoteId: quote.id ?? "")
      }
    case .sellCrypto(let quote, let accountID):
      analyticsService.track(event: AnalyticsEvent(name: .tapsConfirmSell))
      callBioMetric {
        self.apiSellCrypto(accountId: accountID, quoteId: quote.id ?? "")
      }
    }
  }
}

// MARK: - API
extension ConfirmBuySellCryptoViewModel {
  func callBioMetric(onSuccess: @escaping () -> Void) {
    biometricsManager
      .performDeviceAuthentication()
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: { [weak self] completion in
        guard let self else { return }
        switch completion {
        case .finished:
          log.debug("Device authentication check completed.")
        case .failure(let error):
          log.error(error.userFriendlyMessage)
          self.toastMessage = error.userFriendlyMessage
        }
      }, receiveValue: { result in
        if result {
          onSuccess()
        }
      })
      .store(in: &cancellables)
  }
  
  func apiSellCrypto(accountId: String, quoteId: String) {
    Task { @MainActor in
      defer { showIndicator = false }
      showIndicator = true
      do {
        let entity = try await sellCryptoUseCase.execute(accountId: accountId, quoteId: quoteId)
        //TODO: Need handle refresh external list -> Tab Asset Total coin -> Detail Total coin
        navigation = .sellTransactionDetail(entity)
        analyticsService.track(event: AnalyticsEvent(name: .sellCryptoSuccess))
        Haptic.notification(.success).generate()
      } catch {
        analyticsService.track(event: AnalyticsEvent(name: .sellCryptoError))
        Haptic.notification(.error).generate()
        log.error(error.userFriendlyMessage)
        toastMessage = error.userFriendlyMessage
      }
    }
  }
  
  func apiBuyCrypto(accountId: String, quoteId: String) {
    Task { @MainActor in
      defer { showIndicator = false }
      showIndicator = true
      do {
        let entity = try await buyCryptoUseCase.execute(accountId: accountId, quoteId: quoteId)
        //TODO: Need handle refresh external list -> Tab Asset Total coin -> Detail Total coin
        navigation = .buyTransactionDetail(entity)
        analyticsService.track(event: AnalyticsEvent(name: .buyCryptoSuccess))
        Haptic.notification(.success).generate()
      } catch {
        analyticsService.track(event: AnalyticsEvent(name: .buyCryptoError))
        Haptic.notification(.error).generate()
        log.error(error.userFriendlyMessage)
        toastMessage = error.userFriendlyMessage
      }
    }
  }
}

// MARK: - Types
extension ConfirmBuySellCryptoViewModel {
  enum Navigation {
    case sellTransactionDetail(SellCryptoEntity)
    case buyTransactionDetail(BuyCryptoEntity)
  }
  
  enum Kind {
    case buyCrypto(quote: GetBuyQuoteEntity, accountID: String)
    case sellCrypto(quote: GetSellQuoteEntity, accountID: String)
  }
  
  struct RowDetail: Identifiable {
    let title: String
    let value: String
    let valueColor: Color

    init(title: String, value: String, valueColor: Color = Colors.label.swiftUIColor) {
      self.title = title
      self.value = value
      self.valueColor = valueColor
    }

    var id: String {
      title + value
    }
  }
}
