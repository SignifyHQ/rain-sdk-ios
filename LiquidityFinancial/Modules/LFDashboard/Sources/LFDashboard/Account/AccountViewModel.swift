import Combine
import Foundation
import UIKit
import LFUtilities
import Factory
import NetSpendData
import NetspendSdk

@MainActor
class AccountViewModel: ObservableObject {
  var networkEnvironment: NetworkEnvironment {
    EnvironmentManager().networkEnvironment
  }
  
  @LazyInjected(\.netspendRepository) var netspendRepository
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.intercomService) var intercomService

  @Published var navigation: Navigation?
  @Published var popup: Popup?
  @Published var isDisableView: Bool = false
  @Published var isLoading: Bool = false
  @Published var isOpeningPlaidView: Bool = false
  @Published var netspendController: NetspendSdkViewController?
  @Published var toastMessage: String?
}

// MARK: - View Helpers
extension AccountViewModel {
  func selectedAddOption(navigation: Navigation) {
    self.navigation = navigation
  }
}

// MARK: - API
extension AccountViewModel {
  func getATMAuthorizationCode() {
    Task {
      defer {
        isLoading = false
        isDisableView = false
      }
      isLoading = true
      isDisableView = true
      do {
        let sessionID = accountDataManager.sessionID
        let code = try await netspendRepository.getAuthorizationCode(sessionId: sessionID)
        navigation = .atmLocation(code.authorizationCode)
      } catch {
        toastMessage = error.localizedDescription
      }
    }
  }
}

// MARK: - ExternalLinkBank Functions
extension AccountViewModel {
  func linkExternalBank() {
    Task {
      isOpeningPlaidView = true
      isDisableView = true
      do {
        let sessionID = accountDataManager.sessionID
        let tokenResponse = try await netspendRepository.getAuthorizationCode(sessionId: sessionID)
        let controller = try NetspendSdk.shared.openWithPurpose(
          purpose: .linkBank,
          withPasscode: tokenResponse.authorizationCode
        )
        controller.view.isHidden = true
        self.netspendController = controller
      } catch {
        toastMessage = error.localizedDescription
      }
    }
  }
  
  func onPlaidUIDisappear() {
    netspendController = nil
    isOpeningPlaidView = false
    isDisableView = false
  }
  
  func onLinkExternalBankFailure() {
    onPlaidUIDisappear()
    popup = .plaidLinkError
  }
  
  func onLinkExternalBankSuccess() {
    onPlaidUIDisappear()
    navigation = .addMoney
  }
  
  func plaidLinkingErrorPrimaryAction() {
    popup = nil
    navigation = .addBankDebit
  }
  
  func plaidLinkingErrorSecondaryAction() {
    popup = nil
    intercomService.openIntercom()
  }
}

// MARK: - Types
extension AccountViewModel {
  enum Navigation {
    case debugMenu
    case atmLocation(String)
    case bankTransfers
    case addBankDebit
    case addMoney
    case directDeposit
  }
  
  enum Popup {
    case plaidLinkError
  }
}
