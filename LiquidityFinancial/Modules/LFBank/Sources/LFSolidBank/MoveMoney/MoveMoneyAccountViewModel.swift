import Combine
import NetSpendData
import NetspendDomain
import SwiftUI
import LFLocalizable
import LFUtilities
import Factory
import LFStyleGuide
import LFTransaction
import Services
import ExternalFundingData
import SolidDomain
import SolidData
import AccountService

@MainActor
public class MoveMoneyAccountViewModel: ObservableObject {
  @LazyInjected(\.biometricsService) var biometricsService
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.analyticsService) var analyticsService
  @LazyInjected(\.customerSupportService) var customerSupportService
  @LazyInjected(\.externalFundingDataManager) var externalFundingDataManager
  @LazyInjected(\.solidExternalFundingRepository) var solidExternalFundingRepository
  @LazyInjected(\.fiatAccountService) var fiatAccountService
  
  @Published var navigation: Navigation?
  @Published var amountInput: String = Constants.Default.zeroAmount.rawValue
  @Published var cashBalanceValue: String = Constants.Default.zeroAmount.rawValue
  @Published var isFetchingRemainingAmount: Bool = false
  @Published var showIndicator: Bool = false
  @Published var toastMessage: String?
  @Published var inlineError: String?
  @Published var numberOfShakes = 0
  @Published var linkedContacts: [LinkedSourceContact] = []
  @Published var selectedLinkedContact: LinkedSourceContact?
  @Published var selectedValue: GridValue?
  @Published var popup: Popup?
  @Published var showTransferFeeSheet: Bool = false
  @Published var selectTransferInstant: Bool?
  @Published var externalCardFeeResponse: SolidDebitCardTransferFeeResponseEntity?
  
  lazy var solidCreateTransactionUseCase: SolidCreateExternalTransactionUseCaseProtocol = {
    SolidCreateExternalTransactionUseCase(repository: solidExternalFundingRepository)
  }()
  
  lazy var solidEstimateDebitCardFeeUseCase: SolidEstimateDebitCardFeeUseCaseProtocol = {
    SolidEstimateDebitCardFeeUseCase(repository: solidExternalFundingRepository)
  }()
  
  private var cancellable: Set<AnyCancellable> = []
  
  private var cardRemainingAmount: RemainingAvailableAmount?
  private var bankRemainingAmount: RemainingAvailableAmount?
  
  let kind: Kind
  let recommendValues: [GridValue] = [
    .fixed(amount: 10, currency: .usd),
    .fixed(amount: 50, currency: .usd),
    .fixed(amount: 100, currency: .usd)
  ]

  init(kind: Kind, selectedAccount: LinkedSourceContact? = nil) {
    self.kind = kind
    self.selectedLinkedContact = selectedAccount
    
    subscribeLinkedContacts()
    getRemainingAvailableAmount()
  }
  
  var instantFeeString: String {
    guard let amount = externalCardFeeResponse?.fee, amount > 0 else {
      return LFLocalizable.MoveMoney.TransferFeePopup.free
    }
    return amount.formattedUSDAmount()
  }
}

extension MoveMoneyAccountViewModel {
  func getRemainingAvailableAmount() {
    // TODO: Will add this later when BE done
  }
  
  func subscribeLinkedContacts() {
    externalFundingDataManager.subscribeLinkedSourcesChanged { [weak self] contacts in
      guard let self = self else {
        return
      }
      self.linkedContacts = contacts
      if self.selectedLinkedContact == nil {
        self.selectedLinkedContact = contacts.first
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
      }
    }
  }
  
  func callBioMetric() {
    Task {
      if await biometricsService.authenticateWithBiometrics() {
        callTransferAPI()
      }
    }
  }
  
  func continueTransfer() {
    guard let contact = selectedLinkedContact else {
      return
    }
    switch contact.sourceType {
    case .bank:
      callBioMetric()
    case .card:
      getTransactionFee(contact: contact)
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
    navigation = .selectBankAccount
  }
  
  func getTransactionFee(contact: LinkedSourceContact) {
    guard let amount = self.amount.asDouble else {
      toastMessage = LFLocalizable.MoveMoney.Error.noContact
      return
    }
    Task { @MainActor in
      defer { showIndicator = false }
      showIndicator = true
      
      do {
        guard let account = try await self.getDefaultFiatAccount() else {
          return
        }
        let response = try await self.solidEstimateDebitCardFeeUseCase.execute(
          accountId: account.id,
          contactId: contact.sourceId,
          amount: amount
        )
        self.externalCardFeeResponse = response
        showTransferFeeSheet = true
      } catch {
        handleTransferError(error: error)
      }
    }
  }
  
  private func getDefaultFiatAccount() async throws -> AccountModel? {
    if let account = self.accountDataManager.fiatAccounts.first {
      return account
    }
    return try await fiatAccountService.getAccounts().first
  }
  
  func callTransferAPI() {
    guard let contact = selectedLinkedContact, let amount = self.amount.asDouble else {
      toastMessage = LFLocalizable.MoveMoney.Error.noContact
      return
    }
    Task { @MainActor in
      defer {
        showIndicator = false
      }
      showIndicator = true
      do {
        let type: SolidExternalTransactionType = kind == .receive ? .deposit : .withdraw
        guard let account = try await self.getDefaultFiatAccount() else {
          return
        }
        let response = try await solidCreateTransactionUseCase.execute(type: type, accountId: account.id, contactId: contact.sourceId, amount: amount)
        
        analyticsService.track(event: AnalyticsEvent(name: .sendMoneySuccess))
        
        //Push a notification for update transaction list event
        NotificationCenter.default.post(name: .moneyTransactionSuccess, object: nil)
        navigation = .transactionDetai(response.id)
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
    case Constants.ErrorCode.amountTooLow.value:
      popup = .amountTooLow
    case Constants.ErrorCode.bankTransferRequestLimitReached.value:
      popup = .bankLimits
    case Constants.ErrorCode.insufficientFunds.value:
      popup = .insufficientFunds
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
  
  func title(for contact: LinkedSourceContact) -> String {
    switch contact.sourceType {
    case .card:
      return LFLocalizable.ConnectedView.Row.externalCard(contact.last4)
    case .bank:
      return LFLocalizable.ConnectedView.Row.externalBank(contact.name ?? "", contact.last4)
    }
  }
  
  var subtitle: String {
    LFLocalizable.MoveMoney.AvailableBalance.subtitle(
      cashBalanceValue.formattedUSDAmount()
    )
  }

  var annotationString: String {
    LFLocalizable.MoveMoney.Withdraw.annotation(
      cashBalanceValue.formattedUSDAmount()
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
    guard let sourceType = selectedLinkedContact?.sourceType, let amountValue = amount else {
      return nil
    }
    let remainingAmount = sourceType == .card ? cardRemainingAmount : bankRemainingAmount
    guard let remainingAmount = remainingAmount else {
      return nil
    }
    let isReachOut = remainingAmount.day < amountValue || remainingAmount.week < amountValue || remainingAmount.month < amountValue
    if isReachOut {
      return LFLocalizable.TransferView.limitsReached
    }
    return nil
  }
  
  func contactSupport() {
    customerSupportService.openSupportScreen()
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
    case amountTooLow
    case bankLimits
    case insufficientFunds
  }
}
