import SwiftUI
import Factory
import AccountData
import LFUtilities
import Services

// MARK: - SetupWalletViewModel

class SetupWalletViewModel: ObservableObject {
  enum OpenSafariType: Identifiable {
    var id: String {
      switch self {
      case .zerohashURL(let url):
        return url.absoluteString
      case .disclosureURL(let url):
        return url.absoluteString
      case .walletPrivacyURL(let url):
        return url.absoluteString
      }
    }
    
    case zerohashURL(URL)
    case disclosureURL(URL)
    case walletPrivacyURL(URL)
  }
  
  @Published var showIndicator = false
  @Published var toastMessage: String?
  @Published var selection: Int?
  @Published var isTermsAgreed = false
  @Published var isNavigateToRewardsView = false
  
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.customerSupportService) var customerSupportService
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
        toastMessage = error.userFriendlyMessage
        log.error(error.userFriendlyMessage)
      }
    }
  }
  
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }
}
