import Combine
import NetSpendData
import Foundation
import SwiftUI
import LFLocalizable
import LFUtilities
import Factory
import LFStyleGuide

@MainActor
class MoveMoneyAccountViewModel: ObservableObject {
  
  let kind: Kind
  let recommendValues: [GridValue] = [
    .fixed(amount: 10, currency: .usd),
    .fixed(amount: 50, currency: .usd),
    .fixed(amount: 100, currency: .usd)
  ]
  
  @Published var navigation: Navigation?
  @Published var amountInput: String = Constants.Default.zeroAmount.rawValue
  @Published var cashBalanceValue: String = Constants.Default.zeroAmount.rawValue
  @Published var showIndicator: Bool = false
  @Published var toastMessage: String?
  @Published var inlineError: String?
  @Published var numberOfShakes = 0
  @Published var linkedAccount: [APILinkedSourceData] = []
  @Published var selectedLinkedAccount: APILinkedSourceData?
  @Published var selectedValue: GridValue?
  
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.externalFundingRepository) var externalFundingRepository

  init(kind: Kind) {
    self.kind = kind
  }
}

// MARK: Enum
extension MoveMoneyAccountViewModel {
  enum Kind {
    case send
    case receive
  }
  
  enum Navigation {
    case transfer
    case addBankDebit
  }
}

extension MoveMoneyAccountViewModel {
  func appearOperations() {
    Task {
      await refresh()
    }
  }
  
  func refresh() async {
    await withTaskGroup(of: Void.self) { group in
      group.addTask {
        await self.getListConnectedAccount()
      }
    }
  }
  
  func getListConnectedAccount() {
    Task { @MainActor in
      do {
        let sessionID = self.accountDataManager.sessionID
        let response = try await self.externalFundingRepository.getLinkedAccount(sessionId: sessionID)
        let linkedAccount = response.linkedSources.compactMap({
          APILinkedSourceData(
            name: $0.name,
            last4: $0.last4,
            sourceType: APILinkSourceType(rawValue: $0.sourceType.rawString),
            sourceId: $0.sourceId,
            requiredFlow: $0.requiredFlow
          )
        })
        self.linkedAccount = linkedAccount
        self.selectedLinkedAccount = linkedAccount.first
      } catch {
        log.error(error)
      }
    }
  }
  
  func callTransferAPI() {
    guard let linkedAccount = selectedLinkedAccount, let amount = self.amount.asDouble else {
      toastMessage = LFLocalizable.MoveMoney.Error.noContact
      return
    }
    showIndicator = true
    Task { @MainActor in
      defer {
        showIndicator = false
      }
      do {
        let sessionID = self.accountDataManager.sessionID
        let parameters = ExternalTransactionParameters(
          amount: amount,
          sourceId: linkedAccount.sourceId,
          sourceType: linkedAccount.sourceType.rawValue
        )
        let type: ExternalTransactionType = kind == .receive ? .deposit : .withdraw
        let response = try await self.externalFundingRepository.newExternalTransaction(
          parameters: parameters,
          type: type,
          sessionId: sessionID
        )
        log.info("Deposit \(response)")
        navigation = .transfer
      } catch {
        log.error(error.localizedDescription)
      }
    }
  }
}

// MARK: UI Helpers
extension MoveMoneyAccountViewModel {
  func navigateAddAccount() {
    navigation = .addBankDebit
  }
  
  func title(for account: APILinkedSourceData) -> String {
    switch account.sourceType {
    case .externalCard:
      return LFLocalizable.ConnectedView.Row.externalCard(account.last4)
    case .externalBank:
      return LFLocalizable.ConnectedView.Row.externalBank(account.name ?? "", account.last4)
    }
  }
  
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
