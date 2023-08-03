import Combine
import Foundation
import UIKit
import Factory
import NetSpendData
import LFUtilities

class AccountViewModel: ObservableObject {

  enum Navigation {
    case debugMenu
    case atmLocation(String)
    case bankTransfers
    case addBankDebit
    case addMoney
    case directDeposit
  }
  
  var networkEnvironment: NetworkEnvironment {
    EnvironmentManager().networkEnvironment
  }
  
  @LazyInjected(\.netspendRepository) var netspendRepository
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  @LazyInjected(\.accountDataManager) var accountDataManager
  
  @Published var navigation: Navigation?
  @Published var isLoading: Bool = false
  
  init() {

  }
  
  func getATMAuthorizationCode() {
    Task {
      defer { isLoading = false }
      isLoading = true
      do {
        let sessionID = accountDataManager.sessionID
        let code = try await netspendRepository.getAuthorizationCode(sessionId: sessionID)
        navigation = .atmLocation(code.authorizationCode)
      } catch {
        log.error(error)
      }
    }
  }
  
  func selectedAddOption(navigation: Navigation) {
    self.navigation = navigation
  }
}
