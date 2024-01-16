import Combine
import ExternalFundingData
import UIKit
import Factory
import LFUtilities
import LFLocalizable
import Services
import SolidData
import SolidDomain
import LinkKit

class ConnectedAccountsViewModel: ObservableObject {
  
  @LazyInjected(\.analyticsService) var analyticsService
  @LazyInjected(\.customerSupportService) var customerSupportService
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.externalFundingDataManager) var externalFundingDataManager
  @LazyInjected(\.solidExternalFundingRepository) var solidExternalFundingRepository
  
  @Published var linkedContacts: [LinkedSourceContact] = []
  @Published var isDisableView = false
  @Published var isLoading = false
  @Published var isDeleting = false
  @Published var navigation: Navigation?
  @Published var isLoadingLinkExternalBank = false
  @Published var plaidConfig: PlaidConfig?
  @Published var popup: Popup?
  
  lazy var unlinkContactUseCase: SolidUnlinkContactUseCaseProtocol = {
    SolidUnlinkContactUseCase(repository: solidExternalFundingRepository)
  }()
  
  lazy var createPlaidTokenUseCase: CreatePlaidTokenUseCaseProtocol = {
    CreatePlaidTokenUseCase(repository: solidExternalFundingRepository)
  }()
  
  lazy var plaidLinkUseCase: PlaidLinkUseCaseProtocol = {
    PlaidLinkUseCase(repository: solidExternalFundingRepository)
  }()
  
  private var cancellable: Set<AnyCancellable> = []
  
  init(linkedContacts: [LinkedSourceContact]) {
    self.linkedContacts = linkedContacts.filter { $0.sourceType == .bank }
    subscribeLinkedContacts()
  }
  
  func subscribeLinkedContacts() {
    externalFundingDataManager.subscribeLinkedSourcesChanged({ [weak self] contacts in
      self?.linkedContacts = contacts.filter { $0.sourceType == .bank }
    })
    .store(in: &cancellable)
  }
  
}

extension ConnectedAccountsViewModel {

  func trackAccountViewAppear() {
    analyticsService.track(event: AnalyticsEvent(name: .viewedAccounts))
  }
  
  func title(for account: LinkedSourceContact) -> String {
    switch account.sourceType {
    case .card:
      return LFLocalizable.ConnectedView.Row.externalCard(account.last4)
    case .bank:
      return LFLocalizable.ConnectedView.Row.externalBank(account.name ?? "", account.last4)
    }
  }
  
  func openDeletePopup(linkedSource: LinkedSourceContact) {
    popup = .delete(linkedSource: linkedSource)
  }
  
  func hidePopup() {
    popup = nil
  }
  
  func deleteAccount(id: String) {
    self.isDeleting = true
    Task { @MainActor in
      defer {
        isDeleting = false
        hidePopup()
      }
      do {
        let response = try await unlinkContactUseCase.execute(id: id)
        if response.success {
          self.externalFundingDataManager.removeLinkedSource(id: id)
          self.linkedContacts.removeAll(where: {
            $0.sourceId == id
          })
        }
      } catch {
        log.error(error)
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
              self.plaidConfig = PlaidConfig(config: configuration)
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
        navigation = .addMoney
      } catch {
        handleLinkBankFailure(error: error)
      }
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
  
  func plaidLinkingErrorPrimaryAction() {
    popup = nil
    customerSupportService.openSupportScreen()
  }
  
  func handleLinkBankFailure(error: Error) {
    log.error(error.userFriendlyMessage)
    if let liquidError = error as? LiquidityError, liquidError == .userCancelled {
      self.onPlaidUIDisappear()
    } else {
      self.onLinkExternalBankFailure()
    }
  }
}

// MARK: - Types
extension ConnectedAccountsViewModel {
  enum Navigation {
    case addMoney
  }
  
  enum Popup {
    case delete(linkedSource: LinkedSourceContact)
    case plaidLinkingError
  }
}
