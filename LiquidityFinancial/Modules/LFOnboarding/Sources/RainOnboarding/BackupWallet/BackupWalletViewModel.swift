import AccountData
import AccountDomain
import AuthorizationManager
import Factory
import LFLocalizable
import LFUtilities
import PortalSwift
import Services
import SwiftUI

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
  @Published var passwordString: String = ""
  @Published var selectedMethod: BackupMethod?
  
  lazy var refreshPortalToken: RefreshPortalSessionTokenUseCaseProtocol = {
    RefreshPortalSessionTokenUseCase(repository: accountRepository)
  }()
  
  init() {}
}

// MARK: - View Handle
extension BackupWalletViewModel {
  func onBackupMethodSelected(method: BackupMethod) {
    selectedMethod = method
  }
  
  func onBackupButtonTap() {
    guard let selectedMethod else { return }
    
    Task {
      isLoading = true
  
      do {
        let cipher = try await portalService.backup(
          backupMethod: selectedMethod.portalBackupMethod,
          backupConfigs: selectedMethod.backupConfig(with: passwordString)
        )
        
        isLoading = false
        isNavigateToPersonalInformation = true
      } catch {
        handlePortalError(error: error)
      }
    }
  }
  
  func onBackupLaterButtonTap() {
    isNavigateToPersonalInformation = true
  }
  
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }
}

// MARK: - Private Functions
private extension BackupWalletViewModel {
  func handlePortalError(error: Error) {
    guard let portalError = error as? LFPortalError else {
      toastMessage = error.userFriendlyMessage
      isLoading = false
      return
    }
    
    switch portalError {
    case .expirationToken:
      refreshPortalSessionToken()
    default:
      toastMessage = portalError.userFriendlyMessage
      isLoading = false
    }
  }
  
  //TODO: - Will move the refresh token logic to PortalRepository(?)
  func refreshPortalSessionToken() {
    Task {
      do {
        let token = try await refreshPortalToken.execute()
        
        authorizationManager.savePortalSessionToken(token: token.clientSessionToken)
        _ = try await portalService.registerPortal(
          sessionToken: token.clientSessionToken,
          alchemyAPIKey: .empty
        )
        
        onBackupButtonTap()
      } catch {
        isLoading = false
        log.error("An error occurred while refreshing the portal client session \(error)")
      }
    }
  }
}

// MARK: - Types
extension BackupWalletViewModel {
  enum BackupMethod {
    case password
    case iCloud
    
    var portalBackupMethod: BackupMethods {
      switch self {
      case .iCloud:
        return .iCloud
      case .password:
        return .Password
      }
    }
    
    func backupConfig(
      with password: String?
    ) -> BackupConfigs? {
      switch self {
      case .iCloud:
        return nil
      case .password:
        guard let password,
              let passwordStorage = try? PasswordStorageConfig(password: password) else {
          return nil
        }
        
        return BackupConfigs(passwordStorage: passwordStorage)
      }
    }
    
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
