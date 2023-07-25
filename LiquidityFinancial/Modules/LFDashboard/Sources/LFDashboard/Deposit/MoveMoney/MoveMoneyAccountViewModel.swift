import Combine
import Foundation
import SwiftUI
import LFLocalizable
import LFUtilities

@MainActor
class MoveMoneyAccountViewModel: ObservableObject {
  
  let kind: Kind
  let recommendValues: [GridValue] = [
    .fixed(amount: 10, currency: .usd),
    .fixed(amount: 50, currency: .usd),
    .fixed(amount: 100, currency: .usd)
  ]
  
  @Published var amountInput: String = Constants.Default.zeroAmount.rawValue
  @Published var cashBalanceValue: String = Constants.Default.zeroAmount.rawValue
  @Published var showIndicator: Bool = false
  @Published var toastMessage: String?
  @Published var inlineError: String?
  @Published var numberOfShakes = 0
  
  @Published var selectedValue: GridValue?

  init(kind: Kind) {
    self.kind = kind
  }
}

extension MoveMoneyAccountViewModel {
  enum Kind {
    case send
    case receive
  }
}

// MARK: UI Helpers

extension MoveMoneyAccountViewModel {
  var subtitle: String {
    LFLocalizable.MoveMoney.AvailableBalance.subtitle(
      cashBalanceValue.formattedAmount(prefix: Constants.CurrencyUnit.usd.rawValue)
    )
  }

  var annotationString: String {
    LFLocalizable.MoveMoney.Withdraw.annotation(
      cashBalanceValue.formattedAmount(prefix: Constants.CurrencyUnit.usd.rawValue)
    )
  }

  var isAmountActionAllowed: Bool {
    guard let amount = amount.asDouble else {
      return false
    }
    return !(amount.isZero || inlineError.isNotNil)
  }

  var amount: String {
    amountInput.removeDollarSign().removeGroupingSeparator().convertToDecimalFormat()
  }

  func resetSelectedValue() {
    selectedValue = nil
    guard let amount = amountInput.removeGroupingSeparator().asDouble,
          let selectedAmount = selectedValue?.amount
    else {
      return
    }
    amountInput = amount == selectedAmount ? Constants.Default.zeroAmount.rawValue : amountInput
  }

  func onSelectedGridItem(_ gridValue: GridValue) {
    selectedValue = gridValue
    amountInput = gridValue.formattedInput
  }

  func validateAmountInput() {
    numberOfShakes = 0
    inlineError = validateAmount(with: kind)
    if inlineError.isNotNil {
      withAnimation(.linear(duration: 0.5)) {
        numberOfShakes = 4
      }
    }
  }

  func validateAmount(with kind: Kind) -> String? {
    return nil
  }
}
