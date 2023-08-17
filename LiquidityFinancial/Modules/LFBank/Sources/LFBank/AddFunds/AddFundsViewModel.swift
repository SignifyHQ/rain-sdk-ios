import Combine
import SwiftUI
import Factory
import NetSpendData
import NetSpendDomain
import NetspendSdk

@MainActor
final class AddFundsViewModel: ObservableObject {
  @Published var isDisableView: Bool = false
  @Published var isOpeningPlaidView: Bool = false
  @Published var toastMessage: String?
  @Published var netspendController: NetspendSdkViewController?
  @Published var popup: Popup?
  @Published var navigation: Navigation?
  
  @LazyInjected(\.netspendRepository) var netspendRepository
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.intercomService) var intercomService
}

// MARK: - ExternalLinkBank Functions
extension AddFundsViewModel {
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
    popup = .plaidLinkingError
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

// MARK: - View Helpers
extension AddFundsViewModel {
  func selectedAddOption(navigation: Navigation) {
    self.navigation = navigation
  }
}

// MARK: Types
extension AddFundsViewModel {
  enum Navigation {
    case bankTransfers
    case addBankDebit
    case addMoney
    case directDeposit
  }
  
  enum Popup {
    case plaidLinkingError
  }
}
