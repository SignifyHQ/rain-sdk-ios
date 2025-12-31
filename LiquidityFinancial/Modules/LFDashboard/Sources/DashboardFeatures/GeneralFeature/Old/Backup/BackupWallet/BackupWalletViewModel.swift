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
import Services

@MainActor
final class BackupWalletViewModel: ObservableObject {
  @LazyInjected(\.portalRepository) var portalRepository

  @Published var isLoading: Bool = false
  @Published var isBackingUp: Bool = false
  @Published var toastMessage: String?
  
  @Published var backupMethods: [BackupMethod] = []
  @Published var popup: Popup?
  @Published var navigation: Navigation?
  
  private lazy var getBackupMethodsUseCase: GetBackupMethodsUseCaseProtocol = {
    GetBackupMethodsUseCase(repository: portalRepository)
  }()
  
  private lazy var backupWalletUseCase: BackupWalletUseCaseProtocol = {
    BackupWalletUseCase(repository: portalRepository)
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
        let uniqueBackupMethods = Set(response.backupMethods.compactMap({
          $0.components(separatedBy: "-").first
        }))
        backupMethods = uniqueBackupMethods.compactMap {
          BackupMethod(rawValue: $0)
        }
      } catch {
        log.error(error.userFriendlyMessage)
        toastMessage = error.userFriendlyMessage
      }
    }
  }
}

// MARK: - View Handle
extension BackupWalletViewModel {
  func onBackupItemTapped(method: BackupMethod) {
    switch method {
    case .iCloud:
      backupPortalWalletWithIcloud()
    case .password:
      navigation = .setupPIN
    }
  }
  
  func hidePopup() {
    popup = nil
  }
  
  func openDeviceSettings() {
    let mainSettingURL = URL(string:"App-Prefs:root=General&path=ManagedConfigurationList")
    guard let mainSettingURL, UIApplication.shared.canOpenURL(mainSettingURL) else {
      return
    }
    
    UIApplication.shared.open(mainSettingURL)
  }
}

// MARK: - Private Functions
private extension BackupWalletViewModel {
  func handlePortalError(error: Error) {
    guard let portalError = error as? LFPortalError else {
      toastMessage = error.localizedDescription
      return
    }
    
    switch portalError {
    case .iCloudAccountUnavailable:
      popup = .settingICloud
    case .customError(let message):
      toastMessage = message
    default:
      toastMessage = portalError.localizedDescription
    }
    
    log.error(toastMessage ?? error.localizedDescription)
  }
  
  func backupPortalWalletWithIcloud() {
    Task {
      defer { isBackingUp = false }
      isBackingUp = true
      
      do {
        try await backupWalletUseCase.execute(backupMethod: .iCloud, password: nil)
        backupMethods.append(.iCloud)
      } catch {
        handlePortalError(error: error)
      }
    }
  }
  
  func setUpDidBackupByPasswordSuccessObserver() {
    NotificationCenter.default.publisher(for: .didBackupByPasswordSuccess)
      .sink { [weak self] _ in
        guard let self else { return }
        backupMethods.append(.password)
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
    
    var buttonTitle: String {
      switch self {
      case .iCloud:
        return L10N.Common.BackupWallet.BackupWithICloud.title
      case .password:
        return L10N.Common.BackupWallet.SetupPinCode.title
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
  
  enum Popup {
    case settingICloud
  }
}
