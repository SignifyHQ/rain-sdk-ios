import SwiftUI
import LFUtilities
import LFStyleGuide
import LFLocalizable

@MainActor
class DonationInputViewModel: ObservableObject {
  let type: Kind
  var gridValues: [GridValue] = []
  
  @Published var navigation: Navigation?
  @Published var isFetchingData = false
  @Published var isPerformingAction = false
  @Published var amountInput = Constant.initValue
  @Published var numberOfShakes = 0
  @Published var inlineError: String?
  @Published var toastMessage: String?
  
  init(type: Kind) {
    self.type = type
  }
  
  @Published var selectedValue: GridValue? {
    didSet {
      Haptic.selection.generate()
    }
  }
  
  func onAppear() {
    switch type {
    case .buyDonation:
      generateGridValues()
    }
    
    objectWillChange.send()
  }
  
  func continueButtonTapped() {
    Haptic.impact(.light).generate()
//    switch type {
//    case let .buyDonation(fundraiser):
//      if let cashAccount = accountManager.cashAccount {
//        navigation = .detail(
//          .init(type: .buyDonation(fundraiser: fundraiser, amount: "\(amount)", cashAccount: cashAccount))
//        )
//      } else {
//        log.error(LiquidityError.logic, "Unable to show BuySellDetailView without cash account or balance")
//      }
//      break
//    }
  }
  
  private func generateGridValues() {
    switch type {
    case .buyDonation:
      gridValues = Constant.Buy.buildRecommend(available: cashAvailableBalance ?? 0)
    }
  }
}

  // MARK: - UI Helpers

extension DonationInputViewModel {
  var isUSDCurrency: Bool {
    switch type {
    case .buyDonation:
      return true
    }
  }
  
  var isCryptoCurrency: Bool {
    switch type {
    case .buyDonation:
      return false
    }
  }
  
  var maxFractionDigits: Int {
    switch type {
    case .buyDonation:
      return 2
    }
  }
  
  var showDonationsDisclosure: Bool {
    switch type {
    case .buyDonation:
      return true
    }
  }
  
  var showCryptoDisclosure: Bool {
    switch type {
    case .buyDonation:
      return false
    }
  }
  
  var title: String {
    switch type {
    case .buyDonation:
      return "buy_sell_input.buy_donation.title".localizedString.uppercased()
    }
  }
  
  var subtitle: String? {
    switch type {
    case .buyDonation:
      return String(
        format: "available_balance.subtitle".localizedString,
        cashAvailableBalance?.formattedAmount(prefix: "$") ?? "$0.00"
      )
    }
  }
  
  var annotationString: String {
    switch type {
    case .buyDonation:
      return String(
        format: "buy_sell_input.buy_donation_annotation.description".localizedString,
        cashAvailableBalance?.formattedAmount(prefix: "$") ?? "$0.00"
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
    inlineError = validateAmount(
      with: cashAvailableBalance
    )
    if inlineError.isNotNil {
      withAnimation(.linear(duration: 0.5)) {
        numberOfShakes = 4
      }
    }
  }
  
  func validateAmount(with availableBalance: Double?) -> String? {
    guard let balance = availableBalance else { return nil }
    if amount > 0, amount < 0.10 {
      return "buy_sell_amount.minimum_cash".localizedString
    }
    return balance < amount ? "insufficient_funds".localizedString : nil
  }
  
  private var cashAvailableBalance: Double? {
//    guard let balanceStr = accountManager.cashAccount?.availableBalance else {
//      return nil
//    }
//    return balanceStr.asDouble
    return 0
  }
}

  // MARK: - Types

extension DonationInputViewModel {
  enum Kind: Equatable, Identifiable {
    case buyDonation(fundraiser: FundraiserDetailModel)
    
    var id: String {
      switch self {
      case let .buyDonation(fundraiser):
        return "buyDonation-\(fundraiser.id)"
      }
    }
  }
  
  enum Navigation {
    case detail
  }
}

  // MARK: - Constant

extension DonationInputViewModel {
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
  }
}
