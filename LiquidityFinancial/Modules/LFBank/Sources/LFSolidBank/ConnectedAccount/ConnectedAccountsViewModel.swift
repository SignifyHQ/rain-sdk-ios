import Combine
import ExternalFundingData
import UIKit
import Factory
import LFUtilities
import LFLocalizable
import LFServices
import SolidData
import SolidDomain

class ConnectedAccountsViewModel: ObservableObject {
  
  @LazyInjected(\.analyticsService) var analyticsService
  @LazyInjected(\.externalFundingDataManager) var externalFundingDataManager
  @LazyInjected(\.solidExternalFundingRepository) var solidExternalFundingRepository
  
  @Published var linkedContacts: [LinkedSourceContact] = []
  @Published var isLoading = false
  @Published var isDeleting = false
  @Published var navigation: Navigation?
  @Published var popup: Popup?
  
  lazy var unlinkContactUseCase: SolidUnlinkContactUseCaseProtocol = {
    SolidUnlinkContactUseCase(repository: solidExternalFundingRepository)
  }()
  
  private var cancellable: Set<AnyCancellable> = []
  
  init(linkedContacts: [LinkedSourceContact]) {
    self.linkedContacts = linkedContacts
    subscribeLinkedContacts()
  }
  
  func subscribeLinkedContacts() {
    externalFundingDataManager.subscribeLinkedSourcesChanged({ [weak self] contacts in
      self?.linkedContacts = contacts
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
  
  func addBankWithDebit() {
    navigation = .addBankWithDebit
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
}

// MARK: - Types
extension ConnectedAccountsViewModel {
  enum Navigation {
    case addBankWithDebit
  }
  
  enum Popup {
    case delete(linkedSource: LinkedSourceContact)
  }
}
