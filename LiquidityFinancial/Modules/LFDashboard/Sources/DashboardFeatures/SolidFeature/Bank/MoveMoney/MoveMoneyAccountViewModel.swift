import Combine
import NetSpendData
import NetspendDomain
import SwiftUI
import LFLocalizable
import LFUtilities
import Factory
import LFStyleGuide
import Services
import ExternalFundingData
import SolidDomain
import SolidData
import AccountService
import BiometricsManager

@MainActor
public class MoveMoneyAccountViewModel: ObservableObject {
  @LazyInjected(\.biometricsManager) var biometricsManager
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.analyticsService) var analyticsService
  @LazyInjected(\.customerSupportService) var customerSupportService
  @LazyInjected(\.externalFundingDataManager) var externalFundingDataManager
  @LazyInjected(\.solidExternalFundingRepository) var solidExternalFundingRepository
  @LazyInjected(\.fiatAccountService) var fiatAccountService
  
  @Published var isFetchingRemainingAmount = false
  @Published var showIndicator = false
  @Published var isDisableView = false
  @Published var isLoadingLinkExternalBank = false
  @Published var selectTransferInstant: Bool?

  @Published var toastMessage: String?
  @Published var inlineError: String?
  @Published var amountInput = Constants.Default.zeroAmount.rawValue
  @Published var cashBalanceStringValue = Constants.Default.zeroAmount.rawValue
  
  @Published var numberOfShakes = 0
  
  @Published var linkedContacts: [LinkedSourceContact] = []
  @Published var selectedLinkedContact: LinkedSourceContact?
  @Published var selectedValue: GridValue?
  @Published var navigation: Navigation?
  @Published var popup: Popup?
  @Published var sheet: Sheet?
  @Published var externalCardFeeResponse: SolidDebitCardTransferFeeResponseEntity?

  private var cancellable: Set<AnyCancellable> = []
  
  var cashBalance: Double?
  let kind: Kind
  var recommendValues: [GridValue] {
    if kind == .send {
      return buildRecommend(available: cashBalance ?? 0)
    }
    return []
  }
  
  lazy var solidCreateTransactionUseCase: SolidCreateExternalTransactionUseCaseProtocol = {
    SolidCreateExternalTransactionUseCase(repository: solidExternalFundingRepository)
  }()
  
  lazy var solidEstimateDebitCardFeeUseCase: SolidEstimateDebitCardFeeUseCaseProtocol = {
    SolidEstimateDebitCardFeeUseCase(repository: solidExternalFundingRepository)
  }()
  
  lazy var createPlaidTokenUseCase: CreatePlaidTokenUseCaseProtocol = {
    CreatePlaidTokenUseCase(repository: solidExternalFundingRepository)
  }()
  
  lazy var plaidLinkUseCase: PlaidLinkUseCaseProtocol = {
    PlaidLinkUseCase(repository: solidExternalFundingRepository)
  }()
  
  init(kind: Kind, selectedAccount: LinkedSourceContact? = nil, cashBalance: Double? = nil) {
    self.kind = kind
    self.selectedLinkedContact = selectedAccount
    self.cashBalance = cashBalance
    self.cashBalanceStringValue = cashBalance?.formattedUSDAmount() ?? Constants.Default.zeroAmount.rawValue
    
    subscribeLinkedContacts()
  }
}

// MARK: - API
extension MoveMoneyAccountViewModel {
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
        sheet = .transferFee
      } catch {
        handleTransferError(error: error)
      }
    }
  }
  
  func linkExternalBank() {
    Task { @MainActor in
      defer { self.isLoadingLinkExternalBank = false }
      self.isLoadingLinkExternalBank = true
      do {
        let accounts = self.accountDataManager.fiatAccounts
        guard let accountId = accounts.first?.id else {
          return
        }
        let response = try await self.createPlaidTokenUseCase.execute(accountId: accountId)
        let plaidResponse = try await PlaidHelper.createLinkTokenConfiguration(token: response.linkToken, onCreated: { [weak self] configuration in
          guard let self else { return }
          Task {
            await MainActor.run {
              self.sheet = .plaid(PlaidConfig(config: configuration))
              self.isLoadingLinkExternalBank = false
            }
          }
        })
        let solidContact = try await self.plaidLinkUseCase.execute(
          accountId: accountId,
          token: plaidResponse.publicToken,
          plaidAccountId: plaidResponse.plaidAccountId
        )
        addLinkedExternalBank(solidContact: solidContact)
      } catch {
        handleLinkBankFailure(error: error)
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
    sheet = nil
    if selectTransferInstant {
      callBioMetric()
      return
    }
    navigation = .selectBankAccount
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
}

// MARK: UI Helpers
extension MoveMoneyAccountViewModel {
  var subtitle: String {
    LFLocalizable.MoveMoney.AvailableBalance.subtitle(cashBalanceStringValue)
  }
  
  var annotationString: String {
    LFLocalizable.MoveMoney.Withdraw.annotation(cashBalanceStringValue)
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
  
  var transferFeePopupTitle: String {
    let title = kind == .receive
    ? LFLocalizable.MoveMoney.Deposit.title
    : LFLocalizable.MoveMoney.Withdraw.title
    
    return LFLocalizable.MoveMoney.TransferFeePopup.title(title.uppercased())
  }
  
  var instantFeeString: String {
    guard let amount = externalCardFeeResponse?.fee, amount > 0 else {
      return LFLocalizable.MoveMoney.TransferFeePopup.free
    }
    
    return amount.formattedUSDAmount()
  }
  
  func title(for contact: LinkedSourceContact) -> String {
    switch contact.sourceType {
    case .card:
      return LFLocalizable.ConnectedView.Row.externalCard(contact.last4)
    case .bank:
      return LFLocalizable.ConnectedView.Row.externalBank(contact.name ?? "", contact.last4)
    }
  }
  
  func appearOperations() {
    Task {
      do {
        try await self.refreshAccount()
      } catch {
        log.error(error.userFriendlyMessage)
      }
    }
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
    guard kind == .send, let amountValue = amount else { return nil }
    let isReachOut = amountValue > cashBalance ?? 0
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
  
  func plaidLinkingErrorPrimaryAction() {
    popup = nil
    customerSupportService.openSupportScreen()
  }
  
  func buildRecommend(available: Double) -> [GridValue] {
    if available > 1_000 {
      return [
        .fixed(amount: 100, currency: .usd),
        .fixed(amount: 1_000, currency: .usd),
        .all(amount: available, currency: .usd)
      ]
    } else if available > 100 {
      return [
        .fixed(amount: 10, currency: .usd),
        .fixed(amount: 100, currency: .usd),
        .all(amount: available, currency: .usd)
      ]
    } else if available > 10 {
      return [
        .fixed(amount: 1, currency: .usd),
        .fixed(amount: 10, currency: .usd),
        .all(amount: available, currency: .usd)
      ]
    } else {
      return []
    }
  }
}

// MARK: - Private Functions
private extension MoveMoneyAccountViewModel {
  func handleTransferError(error: Error) {
    guard let errorObject = error.asErrorObject else {
      toastMessage = error.userFriendlyMessage
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
  
  func addLinkedExternalBank(solidContact: SolidContactEntity) {
    guard let type = APISolidContactType(rawValue: solidContact.type) else {
      self.onPlaidUIDisappear()
      return
    }
    let contact = LinkedSourceContact(
      name: solidContact.name,
      last4: solidContact.last4,
      sourceType: type == .externalBank ? .bank : .card,
      sourceId: solidContact.solidContactId
    )
    self.externalFundingDataManager.addOrEditLinkedSource(contact)
  }
  
  func onPlaidUIDisappear() {
    isLoadingLinkExternalBank = false
    isDisableView = false
  }
  
  func onLinkExternalBankFailure() {
    onPlaidUIDisappear()
    popup = .plaidLinkingError
  }
  
  func handleLinkBankFailure(error: Error) {
    if let liquidError = error as? LiquidityError, liquidError == .userCancelled {
      self.onPlaidUIDisappear()
    } else {
      self.onLinkExternalBankFailure()
    }
  }
  
  func getDefaultFiatAccount() async throws -> AccountModel? {
    if let account = self.accountDataManager.fiatAccounts.first {
      return account
    }
    return try await fiatAccountService.getAccounts().first
  }
  
  func refreshAccount() async throws {
    guard let accountId = try? await getDefaultFiatAccount()?.id else {
      return
    }
    let account = try await fiatAccountService.getAccountDetail(id: accountId)
    self.accountDataManager.addOrUpdateAccount(account)
    let usdAmount = account.availableUsdBalance.formattedUSDAmount()
    self.cashBalanceStringValue = usdAmount
    self.cashBalance = account.availableBalance
  }
  
  func subscribeLinkedContacts() {
    externalFundingDataManager.subscribeLinkedSourcesChanged { [weak self] contacts in
      guard let self = self else {
        return
      }
      self.linkedContacts = contacts.filter { $0.sourceType == .bank }
      if self.selectedLinkedContact == nil {
        self.selectedLinkedContact = self.linkedContacts.first
      }
    }
    .store(in: &cancellable)
  }
  
  func callBioMetric() {
    biometricsManager.performDeviceAuthentication()
      .sink(receiveCompletion: { [weak self] completion in
        guard let self else { return }
        switch completion {
        case .finished:
          log.debug("Device authentication check completed.")
        case .failure(let error):
          self.toastMessage = error.userFriendlyMessage
        }
      }, receiveValue: { [weak self] result in
        guard let self else { return }
        if result {
          self.callTransferAPI()
        }
      })
      .store(in: &cancellable)
  }
}

// MARK: - Types
extension MoveMoneyAccountViewModel {
  public enum Kind {
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
    case selectBankAccount
  }
  
  enum Popup {
    case limitReached
    case amountTooLow
    case bankLimits
    case insufficientFunds
    case plaidLinkingError
  }
  
  enum Sheet: Identifiable {
    case transferFee
    case plaid(PlaidConfig)
    
    var id: String {
      switch self {
      case .transferFee:
        return "transferFee"
      case .plaid:
        return "plaid"
      }
    }
    
    var isShowTranserFee: Bool {
      switch self {
      case .transferFee:
        return true
      case .plaid:
        return false
      }
    }
  }
}
