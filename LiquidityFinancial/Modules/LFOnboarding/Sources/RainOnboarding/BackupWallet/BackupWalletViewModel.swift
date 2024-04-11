import PortalData
import PortalDomain
import Factory
import LFLocalizable
import LFUtilities
import PortalSwift
import Services
import SwiftUI

@MainActor
final class BackupWalletViewModel: ObservableObject {
  @LazyInjected(\.portalRepository) var portalRepository
  @LazyInjected(\.customerSupportService) var customerSupportService
  @LazyInjected(\.analyticsService) var analyticsService
  @LazyInjected(\.portalService) var portalService
  
  @Published var isLoading = false
  @Published var toastMessage: String?
  @Published var isNavigateToPersonalInformation = false
  @Published var passwordString: String = ""
  @Published var selectedMethod: BackupMethod?
  
  lazy var backupPortalWalletUseCase: BackupPortalWalletUseCaseProtocol = {
    BackupPortalWalletUseCase(repository: portalRepository)
  }()
  
  lazy var walletBackupUseCase: WalletBackupUseCaseProtocol = {
    WalletBackupUseCase(repository: portalRepository)
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
        let cipher = try await backupPortalWalletUseCase.execute(
          backupMethod: selectedMethod.portalBackupMethod,
          backupConfigs: selectedMethod.backupConfig(with: passwordString)
        )
        
        try await walletBackupUseCase.execute(
            cipher: cipher,
            method: selectedMethod.portalBackupMethod.rawValue
          )
        
        isLoading = false
        isNavigateToPersonalInformation = true
        
        log.debug("Portal wallet cipher text saved successfully")
      } catch {
        isLoading = false
        toastMessage = error.userFriendlyMessage
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
