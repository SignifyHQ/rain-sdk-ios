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
  
  @LazyInjected(\.externalFundingRepository) var externalFundingRepository
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  @LazyInjected(\.accountDataManager) var accountDataManager
  
  @Published var linkedAccount: [APILinkedSourceData] = []
  @Published var isLoading = false
  
  init(linkedAccount: [APILinkedSourceData]) {
    self.linkedAccount = linkedAccount
  }
  
}

extension ConnectedAccountsViewModel {

  func title(for account: APILinkedSourceData) -> String {
    switch account.sourceType {
    case .externalCard:
      return LFLocalizable.ConnectedView.Row.externalCard(account.last4)
    case .externalBank:
      return LFLocalizable.ConnectedView.Row.externalBank(account.name ?? "", account.last4)
    }
  }
  
  func deleteAccount(id: String, sourceType: String) {
    self.isLoading = true
    Task { @MainActor in
      defer { isLoading = false }
      do {
        let sessionID = accountDataManager.sessionID
        let response = try await externalFundingRepository.deleteLinkedAccount(
          sessionId: sessionID,
          sourceId: id,
          sourceType: sourceType
        )
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
