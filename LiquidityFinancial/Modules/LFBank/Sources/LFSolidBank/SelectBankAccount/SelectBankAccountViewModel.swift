import Combine
import SolidData
import SolidDomain
import Foundation
import UIKit
import Factory
import NetSpendData
import LFUtilities
import LFLocalizable
import Services
import NetspendSdk
import ExternalFundingData
import AccountService

class SelectBankAccountViewModel: ObservableObject {
  
  var networkEnvironment: NetworkEnvironment {
    EnvironmentManager().networkEnvironment
  }
  
  @LazyInjected(\.externalFundingRepository) var externalFundingRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.biometricsService) var biometricsService
  @LazyInjected(\.analyticsService) var analyticsService
  @LazyInjected(\.customerSupportService) var customerSupportService
  @LazyInjected(\.externalFundingDataManager) var externalFundingDataManager
  @LazyInjected(\.solidExternalFundingRepository) var solidExternalFundingRepository
  @LazyInjected(\.solidAccountRepository) var solidAccountRepository
  @LazyInjected(\.accountServices) var accountServices
  
  @Published var linkedBanks: [LinkedSourceContact] = []
  @Published var navigation: Navigation?
  @Published var selectedBank: LinkedSourceContact?
  @Published var showIndicator: Bool = false
  @Published var toastMessage: String?
  @Published var popup: Popup?
  @Published var linkBankIndicator: Bool = false
  @Published var isDisableView: Bool = false
  @Published var isLoading: Bool = false
  @Published var plaidConfig: PlaidConfig?
  @Published var plaidLoading: Bool = false
  
  let amount: String
  let kind: MoveMoneyAccountViewModel.Kind
  private var fiatAccount: AccountModel?
  
  private var cancellable: Set<AnyCancellable> = []
  private lazy var plaidHelper = PlaidHelper()
  
  lazy var createPlaidTokenUseCase: CreatePlaidTokenUseCaseProtocol = {
    CreatePlaidTokenUseCase(repository: solidExternalFundingRepository)
  }()
  
  lazy var plaidLinkUseCase: PlaidLinkUseCaseProtocol = {
    PlaidLinkUseCase(repository: solidExternalFundingRepository)
  }()
  
  lazy var solidCreateTransactionUseCase: SolidCreateExternalTransactionUseCaseProtocol = {
    SolidCreateExternalTransactionUseCase(repository: solidExternalFundingRepository)
  }()
  
  init(linkedContacts: [LinkedSourceContact], amount: String, kind: MoveMoneyAccountViewModel.Kind) {
    self.linkedBanks = linkedContacts.filter({ data in
      data.sourceType == .bank
    })
    self.amount = amount
    self.kind = kind
    
    subscribeLinkedContacts()
    fetchDefaultFiatAccount()
  }
  
  private func subscribeLinkedContacts() {
    externalFundingDataManager.subscribeLinkedSourcesChanged({ [weak self] contacts in
      guard let self = self else {
        return
      }
      self.linkedBanks = contacts.filter({ data in
        data.sourceType == .bank
      })
    })
    .store(in: &cancellable)
  }
  
  private func fetchDefaultFiatAccount() {
    Task {
      do {
        fiatAccount = self.accountDataManager.fiatAccounts.first
        if fiatAccount == nil {
          fiatAccount = try await accountServices.getFiatAccounts().first
        }
      } catch {
        log.error(error.localizedDescription)
      }
    }
  }
  
  func addNewBankAccount() {
    linkExternalBank()
  }
  
  func continueTapped() {
    guard selectedBank != nil else {
      return
    }
    callBioMetric()
  }
  
  func callBioMetric() {
    Task {
      if await biometricsService.authenticateWithBiometrics() {
        callTransferAPI()
      }
    }
  }
  
  func callTransferAPI() {
    guard let contact = selectedBank, let amount = self.amount.asDouble else {
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
        guard let accountId = fiatAccount?.id else {
          return
        }
        let response = try await solidCreateTransactionUseCase.execute(type: type, accountId: accountId, contactId: contact.sourceId, amount: amount)
        
        analyticsService.track(event: AnalyticsEvent(name: .sendMoneySuccess))
        
        //Push a notification for update transaction list event
        NotificationCenter.default.post(name: .moneyTransactionSuccess, object: nil)
        navigation = .transactionDetail(response.id)
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

  // MARK: - ExternalLinkBank Functions
extension SelectBankAccountViewModel {
  
  func linkExternalBank() {
    Task { @MainActor in
      defer { self.linkBankIndicator = false }
      self.linkBankIndicator = true
      do {
        guard let accountId = fiatAccount?.id else {
          return
        }
        let response = try await self.createPlaidTokenUseCase.execute(accountId: accountId)
        let plaidResponse = try await PlaidHelper.createLinkTokenConfiguration(token: response.linkToken, onCreated: { [weak self] configuration in
          guard let self = self else {
            return
          }
          Task {
            await MainActor.run {
              self.plaidConfig = PlaidConfig(config: configuration)
            }
          }
        })
        let solidContact = try await self.plaidLinkUseCase.execute(
          accountId: accountId,
          token: plaidResponse.publicToken,
          plaidAccountId: plaidResponse.plaidAccountId
        )
        guard let type = APISolidContactType(rawValue: solidContact.type) else {
          self.onPlaidUIDisappear()
          return
        }
        let sourceType: LinkedSourceContactType = type == .externalBank ? .bank : .card
        let contact = LinkedSourceContact(
          name: solidContact.name,
          last4: solidContact.last4,
          sourceType: sourceType,
          sourceId: solidContact.solidContactId
        )
        self.externalFundingDataManager.addOrEditLinkedSource(contact)
      } catch {
        log.error(error.localizedDescription)
        if let liquidError = error as? LiquidityError, liquidError == .userCancelled {
          self.onPlaidUIDisappear()
        } else {
          self.onLinkExternalBankFailure()
        }
      }
    }
  }
  
  func onPlaidUIDisappear() {
    plaidConfig = nil
    linkBankIndicator = false
    isDisableView = false
  }
  
  func onLinkExternalBankFailure() {
    onPlaidUIDisappear()
  }
  
  func contactSupport() {
    customerSupportService.openSupportScreen()
  }
  
  func hidePopup() {
    popup = nil
  }
}

extension SelectBankAccountViewModel {
  
  func title(for contact: LinkedSourceContact) -> String {
    switch contact.sourceType {
    case .card:
      return LFLocalizable.ConnectedView.Row.externalCard(contact.last4)
    case .bank:
      return LFLocalizable.ConnectedView.Row.externalBank(contact.name ?? "", contact.last4)
    }
  }
  
}

  // MARK: - Types
extension SelectBankAccountViewModel {
  enum Navigation {
    case transactionDetail(String)
  }
  
  enum Popup {
    case limitReached
  }
}
