import SwiftUI
import Factory
import PortalData
import PortalDomain
import LFUtilities
import Services
import LFLocalizable

// MARK: - CreateWalletViewModel
@MainActor
final class CreateWalletViewModel: ObservableObject {
  @LazyInjected(\.portalRepository) var portalRepository
  @LazyInjected(\.customerSupportService) var customerSupportService
  @LazyInjected(\.analyticsService) var analyticsService
  @LazyInjected(\.portalService) var portalService
  
  @Published var showIndicator = false
  @Published var toastMessage: String?
  @Published var isTermsAgreed = false
  @Published var isNavigateToBackupWalletView = false
  @Published var openSafariType: OpenSafariType?
  
  lazy var createPortalWalletUseCase: CreatePortalWalletUseCaseProtocol = {
    CreatePortalWalletUseCase(repository: portalRepository)
  }()
  
  lazy var verifyAndUpdatePortalWalletUseCase: VerifyAndUpdatePortalWalletUseCaseProtocol = {
    VerifyAndUpdatePortalWalletUseCase(repository: portalRepository)
  }()
  
  let strMessage = L10N.Common.CreateWallet.termsAndCondition
  let strUserAgreement = L10N.Common.CreateWallet.userAgreement
  let strPrivacy = L10N.Common.CreateWallet.privacyPolicy
  let strDiscloures = L10N.Common.CreateWallet.regulatoryDisclosures
  
  init() {}
}

// MARK: - API Handle
extension CreateWalletViewModel {
  func createPortalWallet() async {
    do {
      let walletAddress = try await createPortalWalletUseCase.execute()
      log.debug("Portal wallet creation successful: \(walletAddress)")
      await verifyAndUpdatePortalWallet()
      
    } catch {
      log.error(error.localizedDescription)
      handlePortalError(error: error)
    }
  }
  
  func verifyAndUpdatePortalWallet() async {
    do {
      _ = try await verifyAndUpdatePortalWalletUseCase.execute()
      
      showIndicator = false
      analyticsService.track(event: AnalyticsEvent(name: .walletSetupSuccess))
      isNavigateToBackupWalletView = true
    } catch {
      log.error(error.localizedDescription)
      showIndicator = false
      toastMessage = error.userFriendlyMessage
    }
  }
}

// MARK: - View Handle
extension CreateWalletViewModel {
  func onCreatePortalWalletTapped() {
    Task {
      showIndicator = true
      guard portalService.checkWalletAddressExists() else {
        await self.createPortalWallet()
        return
      }
      
      await verifyAndUpdatePortalWallet()
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
    case .walletAlreadyExists:
      Task {
        await verifyAndUpdatePortalWallet()
      }
    default:
      toastMessage = portalError.localizedDescription
      showIndicator = false
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
