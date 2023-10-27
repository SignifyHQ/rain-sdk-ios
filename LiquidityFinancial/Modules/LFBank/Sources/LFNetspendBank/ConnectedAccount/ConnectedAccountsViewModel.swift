import Combine
import Foundation
import UIKit
import Factory
import NetSpendData
import LFUtilities
import LFLocalizable
import LFServices
import NetspendDomain

class ConnectedAccountsViewModel: ObservableObject {

  var networkEnvironment: NetworkEnvironment {
    EnvironmentManager().networkEnvironment
  }
  
  @LazyInjected(\.externalFundingRepository) var externalFundingRepository
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.analyticsService) var analyticsService
  
  @Published var linkedAccount: [APILinkedSourceData] = []
  @Published var isLoading = false
  @Published var isDeleting = false
  @Published var navigation: Navigation?
  @Published var popup: Popup?
  
  lazy var deleteLinkedAccountUsecase: NSDeleteLinkedAccountUseCaseProtocol = {
    NSDeleteLinkedAccountUseCase(repository: externalFundingRepository)
  }()
  
  private var cancellable: Set<AnyCancellable> = []
  
  init(linkedAccount: [APILinkedSourceData]) {
    self.linkedAccount = linkedAccount
    subscribeLinkedAccounts()
  }
  
  func subscribeLinkedAccounts() {
    accountDataManager.subscribeLinkedSourcesChanged { [weak self] entities in
      guard let self = self else {
        return
      }
      let linkedSources = entities.compactMap({ APILinkedSourceData(entity: $0) })
      self.linkedAccount = linkedSources
    }
    .store(in: &cancellable)
  }
  
}

extension ConnectedAccountsViewModel {

  func trackAccountViewAppear() {
    analyticsService.track(event: AnalyticsEvent(name: .viewedAccounts))
  }
  
  func title(for account: APILinkedSourceData) -> String {
    switch account.sourceType {
    case .externalCard:
      return LFLocalizable.ConnectedView.Row.externalCard(account.last4)
    case .externalBank:
      return LFLocalizable.ConnectedView.Row.externalBank(account.name ?? "", account.last4)
    }
  }
  
  func verify(sourceData: APILinkedSourceData) {
    navigation = .verifyAccount(id: sourceData.sourceId)
  }
  
  func addBankWithDebit() {
    navigation = .addBankWithDebit
  }
  
  func openDeletePopup(linkedSource: APILinkedSourceData) {
    popup = .delete(linkedSource: linkedSource)
  }
  
  func hidePopup() {
    popup = nil
  }
  
  func deleteAccount(id: String, sourceType: String) {
    self.isDeleting = true
    Task { @MainActor in
      defer {
        isDeleting = false
        hidePopup()
      }
      do {
        let sessionID = accountDataManager.sessionID
        let response = try await deleteLinkedAccountUsecase.execute(
          sessionId: sessionID,
          sourceId: id,
          sourceType: sourceType
        )
        if response.success {
          self.accountDataManager.removeLinkedSource(id: id)
          self.linkedAccount.removeAll(where: {
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
    case verifyAccount(id: String)
    case addBankWithDebit
  }
  
  enum Popup {
    case delete(linkedSource: APILinkedSourceData)
  }
}
