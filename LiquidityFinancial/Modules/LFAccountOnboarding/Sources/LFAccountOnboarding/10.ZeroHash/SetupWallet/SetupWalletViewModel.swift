import SwiftUI
import Factory
import NetSpendData
import AccountData
import LFUtilities
import LFServices
// MARK: - SetupWalletViewModel

class SetupWalletViewModel: ObservableObject {
  @Published var showIndicator = false
  @Published var toastMessage: String?
  @Published var selection: Int?
  @Published var isTermsAgreed = false
  @Published var isNavigateToRewardsView = false
  
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.intercomService) var intercomService
  
  func createZeroHashAccount() {
    Task { @MainActor in
      defer { showIndicator = false }
      showIndicator = true
      do {
        let zeroHashAccount = try await accountRepository.createZeroHashAccount()
        isNavigateToRewardsView = true
        log.debug(zeroHashAccount)
      } catch {
        log.error(error.localizedDescription)
      }
    }
  }
  
  func openIntercom() {
    intercomService.openIntercom()
  }
}
