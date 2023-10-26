import Combine
import UIKit
import Factory
import LFUtilities
import LFLocalizable
import LFServices
import ExternalFundingData

class ConnectedAccountsViewModel: ObservableObject {

  var networkEnvironment: NetworkEnvironment {
    EnvironmentManager().networkEnvironment
  }
  
  @LazyInjected(\.externalFundingRepository) var externalFundingRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.analyticsService) var analyticsService
  @LazyInjected(\.externalFundingDataManager) var externalFundingDataManager
  
  @Published var linkedContacts: [LinkedSourceContact] = []
  @Published var isLoading = false
  @Published var isDeleting = false
  @Published var navigation: Navigation?
  @Published var popup: Popup?
  
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
  
  func deleteAccount(id: String, sourceType: String) {
    // TODO: Implement the delete later
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
