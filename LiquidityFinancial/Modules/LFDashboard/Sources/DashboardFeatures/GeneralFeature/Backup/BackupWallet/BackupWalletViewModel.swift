import Foundation
import LFLocalizable
import Factory
import Combine
import SwiftUI
import LFUtilities
import SwiftUI
import LFStyleGuide
import PortalSwift
import PortalDomain

@MainActor
final class BackupWalletViewModel: ObservableObject {
  @LazyInjected(\.portalRepository) var portalRepository

  @Published var isLoading: Bool = false
  @Published var isBackedUpByPassword: Bool = false
  @Published var toastMessage: String?
  
  @Published var navigation: Navigation?
  
  lazy var getBackupMethodsUseCase: GetBackupMethodsUseCaseProtocol = {
    GetBackupMethodsUseCase(repository: portalRepository)
  }()
  
  private var cancellable: Set<AnyCancellable> = []

  init() {
    fetchBackupMethods()
    setUpDidBackupByPasswordSuccessObserver()
  }
}

// MARK: - API Handle
extension BackupWalletViewModel {
  func fetchBackupMethods() {
    Task {
      isLoading = true
      defer { isLoading = false }
      do {
        let response = try await getBackupMethodsUseCase.execute()
        let backupMethods = response.backupMethods.map {
          BackupMethod(rawValue: $0)
        }
        self.isBackedUpByPassword = backupMethods.contains(.password)
      } catch {
        log.error(error.userFriendlyMessage)
        toastMessage = error.userFriendlyMessage
      }
    }
  }
}

// MARK: - View Handle
extension BackupWalletViewModel {
  func setupPinButtonTapped() {
    navigation = .setupPIN
  }
  
  func setUpDidBackupByPasswordSuccessObserver() {
    NotificationCenter.default.publisher(for: .didBackupByPasswordSuccess)
      .sink { [weak self] _ in
        guard let self else { return }
        self.isBackedUpByPassword = true
        self.navigation = nil
      }
      .store(in: &cancellable)
  }
}

// MARK: - Types
extension BackupWalletViewModel {
  enum BackupMethod: String {
    case iCloud = "ICLOUD"
    case password = "PASSWORD"
    
    var title: String {
      switch self {
      case .iCloud:
        return L10N.Common.BackupWallet.ICloudMethod.title
      case .password:
        return L10N.Common.BackupWallet.PasswordMethod.title
      }
    }
    
    var description: String {
      switch self {
      case .iCloud:
        return L10N.Common.BackupWallet.ICloudMethod.description
      case .password:
        return L10N.Common.BackupWallet.PasswordMethod.description
      }
    }
    
    var image: ImageAsset {
      switch self {
      case .iCloud:
        return GenImages.CommonImages.iCloudBackup
      case .password:
        return GenImages.CommonImages.pinBackup
      }
    }
  }
  
  enum Navigation {
    case setupPIN
  }
}
