import SwiftUI
import Factory
import AccountData
import LFUtilities
import Services
import LFLocalizable
import AuthorizationManager
import AccountDomain

// MARK: - SetupWalletViewModel
@MainActor
final class CreateWalletViewModel: ObservableObject {
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.authorizationManager) var authorizationManager
  @LazyInjected(\.customerSupportService) var customerSupportService
  @LazyInjected(\.analyticsService) var analyticsService
  @LazyInjected(\.portalService) var portalService
  
  @Published var showIndicator = false
  @Published var toastMessage: String?
  @Published var isTermsAgreed = false
  @Published var isNavigateToBackupWalletView = false
  @Published var openSafariType: OpenSafariType?
  
  lazy var refreshPortalToken: RefreshPortalSessionTokenUseCaseProtocol = {
    RefreshPortalSessionTokenUseCase(repository: accountRepository)
  }()
  
  let strMessage = L10N.Common.CreateWallet.termsAndCondition
  let strUserAgreement = L10N.Common.CreateWallet.userAgreement
  let strPrivacy = L10N.Common.CreateWallet.privacyPolicy
  let strDiscloures = L10N.Common.CreateWallet.regulatoryDisclosures
  
  init() {}
}

// MARK: - View Handle
extension CreateWalletViewModel {
  func createPortalWallet() {
    Task {
      showIndicator = true
      
      do {
        let walletAddress = try await portalService.createWallet()
        
        showIndicator = false
        log.debug("Portal wallet creation successful: \(walletAddress)")
        analyticsService.track(event: AnalyticsEvent(name: .walletSetupSuccess))
        isNavigateToBackupWalletView = true
      } catch {
        log.error(error.localizedDescription)
        handlePortalError(error: error)
      }
    }
  }
  
  func onAppear() {
    analyticsService.track(event: AnalyticsEvent(name: .viewsWalletSetup))
  }
  
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }
  
  func onClickedTermLink(link: String) {
    switch link {
    case strUserAgreement:
        break
        // TODO: - Will be replace portal conditional policy
        //      if let url = URL(string: LFUtilities.portalURL) {
        //        openSafariType = .portalURL(url)
        //      }
    case strDiscloures:
      if let url = URL(string: LFUtilities.disclosureURL) {
        openSafariType = .disclosureURL(url)
      }
    case strPrivacy:
      if let url = URL(string: LFUtilities.walletPrivacyURL) {
        openSafariType = .walletPrivacyURL(url)
      }
    default:
      break
    }
  }
}

// MARK: - Private Functions
private extension CreateWalletViewModel {
  func handlePortalError(error: Error) {
    guard let portalError = error as? LFPortalError else {
      toastMessage = error.localizedDescription
      showIndicator = false
      return
    }
    
    switch portalError {
    case .expirationToken:
      refreshPortalSessionToken()
    default:
      toastMessage = portalError.localizedDescription
      showIndicator = false
    }
  }
  
  func refreshPortalSessionToken() {
    Task {
      do {
        let token = try await refreshPortalToken.execute()
        
        authorizationManager.savePortalSessionToken(token: token.clientSessionToken)
        _ = try await portalService.registerPortal(
          sessionToken: token.clientSessionToken,
          alchemyAPIKey: .empty
        )
        createPortalWallet()
      } catch {
        showIndicator = false
        log.error("An error occurred while refreshing the portal client session \(error)")
      }
    }
  }
}

// MARK: - Types
extension CreateWalletViewModel {
  enum OpenSafariType: Identifiable {
    var id: String {
      switch self {
      case .portalURL(let url):
        return url.absoluteString
      case .disclosureURL(let url):
        return url.absoluteString
      case .walletPrivacyURL(let url):
        return url.absoluteString
      }
    }
    
    case portalURL(URL)
    case disclosureURL(URL)
    case walletPrivacyURL(URL)
  }
}
