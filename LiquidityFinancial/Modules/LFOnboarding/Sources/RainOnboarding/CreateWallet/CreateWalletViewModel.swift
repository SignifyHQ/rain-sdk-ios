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
  @LazyInjected(\.rainOnboardingFlowCoordinator) var rainOnboardingFlowCoordinator
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
  
  lazy var backupWalletUseCase: BackupWalletUseCaseProtocol = {
    BackupWalletUseCase(repository: portalRepository)
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
      loadingText = L10N.Common.CreateWallet.CreatePortalWallet.title
      let walletAddress = try await createPortalWalletUseCase.execute()
      log.debug("Portal wallet creation successful: \(walletAddress)")
      
      await backupPortalWalletByIcloud()
    } catch {
      loadingText = .empty
      handlePortalError(error: error)
    }
  }
  
  func verifyAndUpdatePortalWallet() async {
    do {
      loadingText = L10N.Common.CreateWallet.VerifyPortalWallet.title
      _ = try await verifyAndUpdatePortalWalletUseCase.execute()
      
      isNavigateToPersonalInformation = try await rainOnboardingFlowCoordinator.shouldProceedWithOnboarding()
      
      showIndicator = false
      analyticsService.track(event: AnalyticsEvent(name: .walletSetupSuccess))
    } catch {
      loadingText = .empty
      log.error(error.userFriendlyMessage)
      showIndicator = false
      toastMessage = error.userFriendlyMessage
    }
  }
  
  func backupPortalWalletByIcloud() async {
    do {
      loadingText = L10N.Common.CreateWallet.BackupPortalWallet.title
      try await backupWalletUseCase.execute(backupMethod: .iCloud, password: nil)
      
      log.debug(Constants.DebugLog.cipherTextSavedSuccessfully.value)
      await verifyAndUpdatePortalWallet()
    } catch {
      loadingText = .empty
      showIndicator = false
      handlePortalError(error: error)
    }
  }
  
  func checkBackupStatus() async -> Bool {
    do {
      let response = try await getBackupMethodsUseCase.execute()
      let backupMethods = response.backupMethods.map {
        BackupMethods(rawValue: $0)
      }
      return backupMethods.contains(.iCloud)
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
      
      guard let walletAddress = await portalService.getWalletAddress(), !walletAddress.isEmpty else {
        await self.createPortalWallet()
        return
      }
      
      await handleWalletCreationSuccess()
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
  func handleWalletCreationSuccess() async {
    async let isBackedUp = checkBackupStatus()
    
    guard await isBackedUp else {
      await self.backupPortalWalletByIcloud()
      return
    }
    
    await verifyAndUpdatePortalWallet()
  }
  
  func handlePortalError(error: Error) {
    guard let portalError = error as? LFPortalError else {
      toastMessage = error.localizedDescription
      showIndicator = false
      return
    }
    
    switch portalError {
    case .walletAlreadyExists:
      Task {
        await handleWalletCreationSuccess()
      }
    case .iCloudAccountUnavailable:
      showIndicator = false
      popup = .settingICloud
    case .customError(let message):
      toastMessage = message
      showIndicator = false
    default:
      toastMessage = portalError.localizedDescription
      showIndicator = false
    }
    
    log.error(toastMessage ?? error.localizedDescription)
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
