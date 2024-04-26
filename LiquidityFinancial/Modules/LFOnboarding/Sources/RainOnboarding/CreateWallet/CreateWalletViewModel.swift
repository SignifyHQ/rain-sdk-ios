import SwiftUI
import Factory
import PortalData
import PortalDomain
import PortalSwift
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
  @Published var isTermsAgreed = false
  @Published var isNavigateToPersonalInformation = false
  @Published var loadingText: String = .empty
  @Published var toastMessage: String?
  @Published var popup: Popup?
  @Published var openSafariType: OpenSafariType?
  
  lazy var createPortalWalletUseCase: CreatePortalWalletUseCaseProtocol = {
    CreatePortalWalletUseCase(repository: portalRepository)
  }()
  
  lazy var backupPortalWalletUseCase: BackupPortalWalletUseCaseProtocol = {
    BackupPortalWalletUseCase(repository: portalRepository)
  }()
  
  lazy var walletBackupUseCase: WalletBackupUseCaseProtocol = {
    WalletBackupUseCase(repository: portalRepository)
  }()
  
  lazy var verifyAndUpdatePortalWalletUseCase: VerifyAndUpdatePortalWalletUseCaseProtocol = {
    VerifyAndUpdatePortalWalletUseCase(repository: portalRepository)
  }()
  
  lazy var getBackupMethodsUseCase: GetBackupMethodsUseCaseProtocol = {
    GetBackupMethodsUseCase(repository: portalRepository)
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
      loadingText = "Creating Portal Wallet"
      let walletAddress = try await createPortalWalletUseCase.execute()
      log.debug("Portal wallet creation successful: \(walletAddress)")
      
      await backupPortalWalletByIcloud()
    } catch {
      loadingText = .empty
      log.error(error.localizedDescription)
      handlePortalError(error: error)
    }
  }
  
  func verifyAndUpdatePortalWallet() async {
    do {
      loadingText = "Verifying Portal Wallet"
      _ = try await verifyAndUpdatePortalWalletUseCase.execute()
      
      showIndicator = false
      analyticsService.track(event: AnalyticsEvent(name: .walletSetupSuccess))
      isNavigateToPersonalInformation = true
    } catch {
      loadingText = .empty
      log.error(error.localizedDescription)
      showIndicator = false
      toastMessage = error.userFriendlyMessage
    }
  }
  
  func backupPortalWalletByIcloud() async {
    do {
      loadingText = "Backing Up Portal Wallet"
      let cipher = try await backupPortalWalletUseCase.execute(
        backupMethod: .iCloud,
        backupConfigs: nil
      )
      
      try await walletBackupUseCase.execute(
        cipher: cipher,
        method: BackupMethods.iCloud.rawValue
      )
      
      log.debug("Portal wallet cipher text saved successfully")
      await verifyAndUpdatePortalWallet()
    } catch {
      loadingText = .empty
      showIndicator = false
      toastMessage = error.userFriendlyMessage
    }
  }
  
  func checkBackupStatus() async -> Bool {
    do {
      let response = try await getBackupMethodsUseCase.execute()
      return !response.backupMethods.isEmpty
    } catch {
      return false
    }
  }
}

// MARK: - View Handle
extension CreateWalletViewModel {
  func onCreatePortalWalletTapped() {
    Task {
      showIndicator = true
      async let isBackedUp = checkBackupStatus()
      
      guard portalService.checkWalletAddressExists() else {
        await self.createPortalWallet()
        return
      }
      
      guard await isBackedUp else {
        await self.backupPortalWalletByIcloud()
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
  
  func openDeviceSettings() {
    let mainSettingURL = URL(string:"App-Prefs:root=General&path=ManagedConfigurationList")
    guard let mainSettingURL, UIApplication.shared.canOpenURL(mainSettingURL) else {
      return
    }
    
    UIApplication.shared.open(mainSettingURL)
  }
  
  func hidePopup() {
    popup = nil
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
    case .iCloudAccountUnavailable:
      showIndicator = false
      popup = .settingICloud
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
  
  enum Popup {
    case settingICloud
  }
}
