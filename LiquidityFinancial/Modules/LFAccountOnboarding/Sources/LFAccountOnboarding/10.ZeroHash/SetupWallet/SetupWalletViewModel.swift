import SwiftUI
import Factory
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
  @LazyInjected(\.customSupportService) var customSupportService
  @LazyInjected(\.analyticsService) var analyticsService
  
  func createZeroHashAccount() {
    Task { @MainActor in
      defer { showIndicator = false }
      showIndicator = true
      do {
        let zeroHashAccount = try await accountRepository.createZeroHashAccount()
        isNavigateToRewardsView = true
        log.debug(zeroHashAccount)
        analyticsService.track(event: AnalyticsEvent(name: .walletSetupSuccess))
      } catch {
        toastMessage = error.localizedDescription
        log.error(error.localizedDescription)
      }
    }
  }
  
  func openSupportScreen() {
    customSupportService.openSupportScreen()
  }
}
