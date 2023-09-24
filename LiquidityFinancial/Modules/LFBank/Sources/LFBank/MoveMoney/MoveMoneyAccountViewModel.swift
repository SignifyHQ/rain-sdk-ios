import Combine
import NetSpendData
import NetSpendDomain
import Foundation
import SwiftUI
import LFLocalizable
import LFUtilities
import Factory
import LFStyleGuide
import LFTransaction
import LFServices

@MainActor
public class MoveMoneyAccountViewModel: ObservableObject {
  @LazyInjected(\.authenticationService) var authenticationService
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.externalFundingRepository) var externalFundingRepository
  @LazyInjected(\.analyticsService) var analyticsService
  @LazyInjected(\.intercomService) var intercomService
  
  @Published var navigation: Navigation?
  @Published var amountInput: String = Constants.Default.zeroAmount.rawValue
  @Published var cashBalanceValue: String = Constants.Default.zeroAmount.rawValue
  @Published var isFetchingRemainingAmount: Bool = false
  @Published var showIndicator: Bool = false
  @Published var toastMessage: String?
  @Published var inlineError: String?
  @Published var numberOfShakes = 0
  @Published var linkedAccount: [APILinkedSourceData] = []
  @Published var selectedLinkedAccount: APILinkedSourceData?
  @Published var selectedValue: GridValue?
  @Published var popup: Popup?
  @Published var showTransferFeeSheet: Bool = false
  @Published var selectTransferInstant: Bool?
  
  private var cancellable: Set<AnyCancellable> = []
  
  private var cardRemainingAmount = RemainingAvailableAmount.default
  private var bankRemainingAmount = RemainingAvailableAmount.default
  
  let kind: Kind
  let recommendValues: [GridValue] = [
    .fixed(amount: 10, currency: .usd),
    .fixed(amount: 50, currency: .usd),
    .fixed(amount: 100, currency: .usd)
  ]

  init(kind: Kind, selectedAccount: APILinkedSourceData? = nil) {
    self.kind = kind
    self.selectedLinkedAccount = selectedAccount
    
    subscribeLinkedAccounts()
    getRemainingAvailableAmount()
  }
}

extension MoveMoneyAccountViewModel {
  func getRemainingAvailableAmount() {
    Task {
      defer { isFetchingRemainingAmount = false }
      isFetchingRemainingAmount = true
      
      do {
        let cardRemainingAmount = try await externalFundingRepository.getCardRemainingAmount(
          sessionID: accountDataManager.sessionID,
          type: kind.externalTransactionType
        )
        let bankRemainingAmount = try await externalFundingRepository.getBankRemainingAmount(
          sessionID: accountDataManager.sessionID,
          type: kind.externalTransactionType
        )
        self.cardRemainingAmount = RemainingAvailableAmount(
          from: cardRemainingAmount.map {
            TransferLimitConfig(from: $0)
          }
        )
        self.bankRemainingAmount = RemainingAvailableAmount(
          from: bankRemainingAmount.map {
            TransferLimitConfig(from: $0)
          }
        )
      } catch {
        log.error(error.localizedDescription)
      }
    }
  }
  
  func subscribeLinkedAccounts() {
    accountDataManager.subscribeLinkedSourcesChanged { [weak self] entities in
      guard let self = self else {
        return
      }
      let linkedSources = entities.compactMap({ $0.isVerified ? APILinkedSourceData(entity: $0) : nil })
      self.linkedAccount = linkedSources
      if self.selectedLinkedAccount == nil {
        self.selectedLinkedAccount = linkedSources.first
      }
    }
    .store(in: &cancellable)
  }
  
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
  
  func callBioMetric() {
    Task {
      if await authenticationService.authenticateWithBiometrics() {
        callTransferAPI()
      }
    }
  }
  
  func continueTransfer() {
    guard let account = selectedLinkedAccount else {
      return
    }
    switch account.sourceType {
    case .externalBank:
      callBioMetric()
    case .externalCard:
      showTransferFeeSheet = true
    }
  }
  
  func continueTransferFeePopup() {
    guard let selectTransferInstant = selectTransferInstant else {
      return
    }
    showTransferFeeSheet = false
    if selectTransferInstant {
      callBioMetric()
      return
    }
    let linkedBanks = linkedAccount.filter { data in
      data.isVerified && data.sourceType == .externalBank
    }
    navigation = .selectBankAccount
  }
  
  func getListConnectedAccount() {
    Task { @MainActor in
      do {
        let sessionID = self.accountDataManager.sessionID
        async let response = self.externalFundingRepository.getLinkedAccount(sessionId: sessionID)
        let linkedSources = try await response.linkedSources
        self.accountDataManager.storeLinkedSources(linkedSources)
      } catch {
        toastMessage = error.localizedDescription
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
        
        analyticsService.track(event: AnalyticsEvent(name: .sendMoneySuccess))
        
        //Push a notification for update transaction list event
        NotificationCenter.default.post(name: .moneyTransactionSuccess, object: nil)
        
        navigation = .transactionDetai(response.transactionId)
      } catch {
        handleTransferError(error: error)
      }
    }
  }
  
  func handleTransferError(error: Error) {
    guard let errorObject = error.asErrorObject else {
      toastMessage = error.localizedDescription
      return
    }
    switch errorObject.code {
    case Constants.ErrorCode.transferLimitExceeded.value:
      popup = .limitReached
    default:
      toastMessage = errorObject.message
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
    inlineError = validateAmount(with: amount.asDouble)
    if inlineError.isNotNil {
      withAnimation(.linear(duration: 0.5)) {
        numberOfShakes = 4
      }
    }
  }
  
  func validateAmount(with amount: Double?) -> String? {
    guard let sourceType = selectedLinkedAccount?.sourceType, let amountValue = amount else {
      return nil
    }
    let remainingAmount = sourceType == .externalCard ? cardRemainingAmount : bankRemainingAmount
    let isReachOut = remainingAmount.day < amountValue || remainingAmount.week < amountValue || remainingAmount.month < amountValue
    if isReachOut {
      return LFLocalizable.TransferView.limitsReached
    }
    return nil
  }
  
  func contactSupport() {
    intercomService.openIntercom()
  }
  
  func hidePopup() {
    popup = nil
  }
  
  var transferFeePopupTitle: String {
    let title = kind == .receive ? LFLocalizable.MoveMoney.Deposit.title : LFLocalizable.MoveMoney.Withdraw.title
    return LFLocalizable.MoveMoney.TransferFeePopup.title(title.uppercased())
  }
}

// MARK: - Types
public extension MoveMoneyAccountViewModel {
  enum Kind {
    case send
    case receive

    var externalTransactionType: String {
      switch self {
      case .receive:
        return "deposit"
      case .send:
        return "withdraw"
      }
    }
  }
  
  enum Navigation {
    case transactionDetai(String)
    case addBankDebit
    case selectBankAccount
  }
  
  enum Popup {
    case limitReached
  }
}
