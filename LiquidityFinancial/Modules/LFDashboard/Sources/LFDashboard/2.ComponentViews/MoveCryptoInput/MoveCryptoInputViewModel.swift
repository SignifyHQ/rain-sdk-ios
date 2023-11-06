import SwiftUI
import BaseDashboard
import LFLocalizable
import LFUtilities
import LFStyleGuide
import Factory
import AccountDomain
import Combine
import ZerohashDomain
import AccountService

@MainActor
final class MoveCryptoInputViewModel: ObservableObject {
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.zerohashRepository) var zerohashRepository
  @LazyInjected(\.dashboardRepository) var dashboardRepository
  @LazyInjected(\.cryptoAccountService) var cryptoAccountService

  @Published var assetModel: AssetModel
  @Published var fiatAccount: AccountModel?
  
  @Published var navigation: Navigation?
  @Published var isFetchingData = false
  @Published var isPerformingAction = false
  @Published var amountInput = "0"
  @Published var numberOfShakes = 0
  @Published var inlineError: String?
  @Published var toastMessage: String?
  @Published var selectedValue: GridValue? {
    didSet {
      Haptic.selection.generate()
    }
  }
  
  let type: Kind
  var gridValues: [GridValue] = []
  private var subscribers: Set<AnyCancellable> = []
  
  init(type: Kind, assetModel: AssetModel) {
    self.type = type
    self.assetModel = assetModel
    getAccount()
    observeAccounts()
    generateGridValues()
  }
  
  var address: String {
    switch type {
    case .sendCrypto(let address, _):
      return address
    default:
      return .empty
    }
  }
  
  var nickname: String {
    switch type {
    case .sendCrypto(_, let nickname):
      return nickname ?? .empty
    default:
      return .empty
    }
  }
  
  func continueButtonTapped() {
    Haptic.impact(.light).generate()
    switch type {
    case .buyCrypto:
      fetchBuyCryptoQuote(amount: "\(amount)")
    case .sellCrypto:
      fetchSellCryptoQuote(amount: "\(amount)")
    case .sendCrypto:
      if accountDataManager.featureConfig?.isSendCryptoV2Enabled ?? false {
        fetchSendCryptoQuote(amount: amount, address: address)
      } else {
        navigation = .confirmSend()
      }
    }
  }
  
  private func generateGridValues() {
    switch type {
    case .buyCrypto:
      gridValues = Constant.Buy.buildRecommend(available: fiatAccount?.availableBalance ?? 0)
    case .sellCrypto, .sendCrypto:
      gridValues = Constant.Sell.buildRecommend(available: assetModel.availableBalance)
    }
  }
  
  private func observeAccounts() {
    accountDataManager
      .accountsSubject
      .receive(on: DispatchQueue.main)
      .sink(receiveValue: { [weak self] accounts in
      guard let self = self else {
        return
      }
      if let cryptoAccount = accounts.first(where: {
        $0.id == self.assetModel.id
      }) {
        self.assetModel = AssetModel(account: cryptoAccount)
      }
      self.fiatAccount = accounts.first(where: { account in
        account.currency.isFiat
      })
    })
    .store(in: &subscribers)
  }
}

// MARK: - API logic
private extension MoveCryptoInputViewModel {
  func getAccount() {
    let cryptoId = self.assetModel.id
    Task {
      if type == .buyCrypto {
        let fiatAccounts = try await self.dashboardRepository.getFiatAccounts()
        self.accountDataManager.addOrUpdateAccounts(fiatAccounts)
        
        if let fiatAccount = fiatAccounts.first {
          self.accountDataManager.fiatAccountID = fiatAccount.id
        }
      }
      let cryptoAccount = try await self.cryptoAccountService.getAccountDetail(id: cryptoId)
      self.accountDataManager.addOrUpdateAccount(cryptoAccount)
      self.accountDataManager.cryptoAccountID = cryptoId
      
      generateGridValues()
    }
  }
  
  func fetchSendCryptoQuote(amount: Double, address: String) {
    Task {
      defer { isPerformingAction = false }
      isPerformingAction = true
      do {
        let lockedResponse = try await self.zerohashRepository.lockedNetworkFee(
          accountId: assetModel.id,
          destinationAddress: address,
          amount: amount,
          maxAmount: isMaxAmount
        )
        navigation = .confirmSend(lockedFeeResponse: lockedResponse)
      } catch {
        self.toastMessage = error.localizedDescription
      }
    }
  }
  
  func fetchBuyCryptoQuote(amount: String) {
    //    guard let account = accountManager.cryptoAccount else { return }
    //    isPerformingAction = true
    //    Task {
    //      do {
    //        let quote: CryptoQuoteDetail = try await networkService.handle(request: Endpoints.createCryptoQuote(walletID: account.id, paymentType: "amount", amtValue: amount))
    //        if let cashAccount = accountManager.cashAccount {
    //          navigation = .detail(.init(type: .buyCrypto(quote: quote, cryptoAccount: account, cashAccount: cashAccount)))
    //        } else {
    //          log.error(LiquidityError.logic, "Unable to show BuySellDetailView without accounts")
    //        }
    //      } catch {
    //        log.error(error, "failed to get buy quote for crypto")
    //        toastMessage = error.localizedDescription
    //      }
    //      isPerformingAction = false
    //    }
  }
  
  func fetchSellCryptoQuote(amount: String) {
    //    guard let account = accountManager.cryptoAccount else { return }
    //    isPerformingAction = true
    //    Task {
    //      do {
    //        let quote: CryptoQuoteDetail = try await networkService.handle(request: Endpoints.sellCryptoQuote(walletID: account.id, paymentType: "quantity", amtValue: amount))
    //        if let cashAccount = accountManager.cashAccount {
    //          navigation = .detail(.init(type: .sellCrypto(quote: quote, cryptoAccount: account, cashAccount: cashAccount)))
    //        } else {
    //          log.error(LiquidityError.logic, "Unable to show BuySellDetailView without accounts")
    //        }
    //      } catch {
    //        log.error(error, "failed to get sell quote for crypto")
    //        toastMessage = error.localizedDescription
    //      }
    //      isPerformingAction = false
    //    }
  }
}

// MARK: - View Helpers
extension MoveCryptoInputViewModel {
  var isUSDCurrency: Bool {
    switch type {
    case .buyCrypto:
      return true
    case .sellCrypto, .sendCrypto:
      return false
    }
  }
  
  var isCryptoCurrency: Bool {
    switch type {
    case .buyCrypto:
      return false
    case .sellCrypto, .sendCrypto:
      return true
    }
  }
  
  var maxFractionDigits: Int {
    switch type {
    case .buyCrypto:
      return 2
    case .sellCrypto, .sendCrypto:
      return LFUtilities.cryptoFractionDigits
    }
  }
  
  var showCryptoDisclosure: Bool {
    true
  }
  
  var showEstimatedFeeDescription: Bool {
    switch type {
    case .sendCrypto:
      return true
    default:
      return false
    }
  }
  
  var title: String {
    switch type {
    case .buyCrypto:
      return LFLocalizable.MoveCryptoInput.Buy.title
    case .sellCrypto:
      return LFLocalizable.MoveCryptoInput.Sell.title
    case .sendCrypto:
      return LFLocalizable.MoveCryptoInput.Send.title
    }
  }
  
  var subtitle: String? {
    switch type {
    case .buyCrypto:
      return LFLocalizable.MoveCryptoInput.BuyAvailableBalance.subtitle(
        fiatAccount?.availableBalance.formattedUSDAmount() ?? "$0.00"
      )
    case .sellCrypto:
      let balance = assetModel.availableBalance.roundTo3f()
      return LFLocalizable.MoveCryptoInput.SellAvailableBalance.subtitle(
        "\(balance)".formattedAmount(minFractionDigits: 3, maxFractionDigits: 3), LFUtilities.cryptoCurrency.uppercased()
      )
    case .sendCrypto:
      let balance = assetModel.availableBalance.roundTo3f()
      return LFLocalizable.MoveCryptoInput.SendAvailableBalance.subtitle(
        "\(balance)".formattedAmount(minFractionDigits: 3, maxFractionDigits: 3), LFUtilities.cryptoCurrency.uppercased()
      )
    }
  }
  
  var annotationString: String {
    switch type {
    case .buyCrypto:
      return LFLocalizable.MoveCryptoInput.Buy.annotation(
        fiatAccount?.availableBalance.formattedUSDAmount() ?? "$0.00"
      )
    case .sellCrypto:
      let balance = assetModel.availableBalance.roundTo3f()
      return LFLocalizable.MoveCryptoInput.Sell.annotation(
        "\(balance)".formattedAmount(minFractionDigits: 3, maxFractionDigits: 3)
      )
    case .sendCrypto:
      let balance = assetModel.availableBalance.roundTo3f()
      return LFLocalizable.MoveCryptoInput.Send.annotation(
        "\(balance)".formattedAmount(minFractionDigits: 3, maxFractionDigits: 3)
      )
    }
  }
  
  var isActionAllowed: Bool {
    !(amount.isZero || inlineError.isNotNil)
  }
  
  var amount: Double {
    amountInput.removeGroupingSeparator().convertToDecimalFormat().asDouble ?? 0.0
  }
  
  /// Reset amountInput and selectedValue when interacting with keyboard
  func resetSelectedValue() {
    selectedValue = nil
    guard let amount = amountInput.removeGroupingSeparator().asDouble,
          let selectedAmount = selectedValue?.amount
    else {
      return
    }
    amountInput = amount == selectedAmount ? Constant.initValue : amountInput
  }
  
  func onSelectedGridItem(_ gridValue: GridValue) {
    selectedValue = gridValue
    amountInput = gridValue.formattedInput
  }
  
  func validateAmountInput() {
    numberOfShakes = 0
    switch type {
    case .sellCrypto, .sendCrypto:
      inlineError = validateAmount(with: assetModel.availableBalance)
    case .buyCrypto:
      inlineError = validateAmount(with: fiatAccount?.availableBalance)
    }
    if inlineError.isNotNil {
      withAnimation(.linear(duration: 0.5)) {
        numberOfShakes = 4
      }
    }
  }
  
  func validateAmount(with availableBalance: Double?) -> String? {
    guard let balance = availableBalance else { return nil }
    if type != .sellCrypto, amount > 0, amount < 0.10 {
      return LFLocalizable.MoveCryptoInput.MinimumCash.description
    }
    return balance < amount ? LFLocalizable.MoveCryptoInput.InsufficientFunds.description : nil
  }
  
  var isMaxAmount: Bool {
    switch type {
    case .sendCrypto, .sellCrypto:
      return amount >= assetModel.availableBalance
    default:
      return false
    }
  }
}

// MARK: - Types
extension MoveCryptoInputViewModel {
  enum Kind: Equatable, Identifiable {
    case buyCrypto
    case sellCrypto
    case sendCrypto(address: String, nickname: String?)
    
    var id: String {
      switch self {
      case .buyCrypto:
        return "buyCrypto"
      case .sellCrypto:
        return "sellCrypto"
      case .sendCrypto:
        return "sendCrypto"
      }
    }
  }
  
  enum Navigation {
    case detail
    case confirmSend(lockedFeeResponse: APILockedNetworkFeeResponse? = nil)
  }
}

// MARK: - Constant
extension MoveCryptoInputViewModel {
  private enum Constant {
    static let initValue = "0"
    enum Buy {
      static func buildRecommend(available: Double) -> [GridValue] {
        if available > 500 {
          return [.fixed(amount: 100, currency: .usd), .fixed(amount: 200, currency: .usd), .fixed(amount: 500, currency: .usd)]
        } else if available > 200 {
          return [.fixed(amount: 50, currency: .usd), .fixed(amount: 100, currency: .usd), .fixed(amount: 200, currency: .usd)]
        } else if available > 100 {
          return [.fixed(amount: 10, currency: .usd), .fixed(amount: 50, currency: .usd), .fixed(amount: 100, currency: .usd)]
        } else {
          return []
        }
      }
    }
    
    enum Sell {
      static func buildRecommend(available: Double) -> [GridValue] {
        if available > 1_000 {
          return [.fixed(amount: 100, currency: .crypto), .fixed(amount: 1_000, currency: .crypto), .all(amount: available, currency: .crypto)]
        } else if available > 100 {
          return [.fixed(amount: 10, currency: .crypto), .fixed(amount: 100, currency: .crypto), .all(amount: available, currency: .crypto)]
        } else if available > 10 {
          return [.fixed(amount: 1, currency: .crypto), .fixed(amount: 10, currency: .crypto), .all(amount: available, currency: .crypto)]
        } else {
          return []
        }
      }
    }
  }
}

struct CryptoBalance: Codable {
  let availableSendBalance: String
  let availableSellBalance: String
}
