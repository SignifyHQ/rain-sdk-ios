import Combine
import Foundation
import UIKit
import Factory
import NetSpendData
import LFUtilities
import LFLocalizable

class ConnectedAccountsViewModel: ObservableObject {

  var networkEnvironment: NetworkEnvironment {
    EnvironmentManager().networkEnvironment
  }
  
  @LazyInjected(\.netspendRepository) var netspendRepository
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  @LazyInjected(\.accountDataManager) var accountDataManager
  
  @Published var linkedAccount: [NetSpendLinkedSourceData] = []
  @Published var isLoading = false
  
  init(linkedAccount: [NetSpendLinkedSourceData]) {
    self.linkedAccount = linkedAccount
  }
  
}

extension ConnectedAccountsViewModel {

  func title(for account: NetSpendLinkedSourceData) -> String {
    switch account.sourceType {
    case .externalCard:
      return LFLocalizable.ConnectedView.Row.externalCard(account.last4)
    case .externalBank:
      return LFLocalizable.ConnectedView.Row.externalBank(account.bankName ?? "", account.last4)
    }
  }
  
  func deleteAccount(id: String) {
    self.isLoading = true
    Task { @MainActor in
      defer { isLoading = false }
      do {
        let sessionID = accountDataManager.sessionID
        let response = try await netspendRepository.deleteLinkedAccount(sessionId: sessionID, sourceId: id)
        if response.success {
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
