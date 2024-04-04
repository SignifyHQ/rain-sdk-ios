import SwiftUI
import Factory
import AccountData
import LFUtilities
import Services
import LFLocalizable
import AuthorizationManager
import AccountDomain

@MainActor
final class BackupWalletViewModel: ObservableObject {
  @LazyInjected(\.authorizationManager) var authorizationManager
  @LazyInjected(\.accountRepository) var accountRepository
  @LazyInjected(\.customerSupportService) var customerSupportService
  @LazyInjected(\.analyticsService) var analyticsService
  @LazyInjected(\.portalService) var portalService
  
  @Published var isLoading = false
  @Published var toastMessage: String?
  @Published var isNavigateToPersonalInformation = false
  @Published var selectedMethod: BackupMethods?
  
  lazy var refreshPortalToken: RefreshPortalSessionTokenUseCaseProtocol = {
    RefreshPortalSessionTokenUseCase(repository: accountRepository)
  }()
  
  init() {}
}

// MARK: - View Handle
extension BackupWalletViewModel {
  func onSelectedBackupMethod(method: BackupMethods) {
    selectedMethod = method
  }
  
  func onClickedBackupButton() {
    // TODO: - Will be implemented later
    isNavigateToPersonalInformation = true
  }
  
  func onClickedBackupLaterButton() {
    isNavigateToPersonalInformation = true
  }
  
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }
}

// MARK: - Types
extension BackupWalletViewModel {
  enum BackupMethods {
    case password
    case iCloud
    
    var title: String {
      switch self {
      case .password:
        return L10N.Common.BackupWallet.PasswordMethod.title
      case .iCloud:
        return L10N.Common.BackupWallet.ICloudMethod.title
      }
    }
  }
}
