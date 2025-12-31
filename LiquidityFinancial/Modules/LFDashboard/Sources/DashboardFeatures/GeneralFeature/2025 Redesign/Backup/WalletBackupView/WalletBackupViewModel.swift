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
final class WalletBackupViewModel: ObservableObject {
  @LazyInjected(\.portalRepository) var portalRepository
  
  @Published var isLoading: Bool = false
  @Published var toastMessage: String?
  @Published var backupMethods: [BackupMethod] = []
  @Published var popup: Popup?
  
  var lastUpdatedCloudBackupAt: String?
  
  private lazy var getBackupMethodsUseCase: GetBackupMethodsUseCaseProtocol = {
    GetBackupMethodsUseCase(repository: portalRepository)
  }()
  
  private lazy var backupWalletUseCase: BackupWalletUseCaseProtocol = {
    BackupWalletUseCase(repository: portalRepository)
  }()
  
  private var cancellable: Set<AnyCancellable> = []
  
  init() {
    fetchBackupMethods(isAnimated: true)
    setUpDidBackupByPasswordSuccessObserver()
  }
}

// MARK: - APIs Handle
extension WalletBackupViewModel {
  func fetchBackupMethods(
    isAnimated: Bool
  ) {
    Task {
      defer {
        isLoading = false
      }
      
      if isAnimated {
        isLoading = true
      }
      
      do {
        let response = try await getBackupMethodsUseCase.execute()
        lastUpdatedCloudBackupAt = response.lastAdded?.updatedAt?.parsingDateStringToNewFormat(toDateFormat: .dayMonthYear)
        
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

// MARK: - Observable
extension WalletBackupViewModel {
  func setUpDidBackupByPasswordSuccessObserver() {
    NotificationCenter.default.publisher(for: .didBackupByPasswordSuccess)
      .sink { [weak self] _ in
        guard let self else { return }
        backupMethods.append(.password)
      }
      .store(in: &cancellable)
  }
}

// MARK: - Handle Interactions
extension WalletBackupViewModel {
  func onBackupItemTapped(method: BackupMethod) {
    switch method {
    case .iCloud:
      popup = .settingICloud
    case .password:
      popup = .enterNewPin
    }
  }
  
  func hidePopup() {
    popup = nil
  }
}

// MARK: - Enums
extension WalletBackupViewModel {
  enum BackupMethod: String {
    case iCloud = "ICLOUD"
    case password = "PASSWORD"
    
    var title: String {
      switch self {
      case .iCloud:
        return L10N.Common.WalletBackup.Icloud.title
      case .password:
        return L10N.Common.WalletBackup.Pin.title
      }
    }
    
    var description: String {
      switch self {
      case .iCloud:
        return L10N.Common.WalletBackup.Icloud.subtitle
      case .password:
        return L10N.Common.WalletBackup.Pin.subtitle
      }
    }
    
    var buttonTitle: String {
      switch self {
      case .iCloud:
        return L10N.Common.WalletBackup.Icloud.Update.Button.title
      case .password:
        return L10N.Common.WalletBackup.Pin.Update.Button.title
      }
    }
    
    var imageView: some View {
      switch self {
      case .iCloud:
        return GenImages.Images.icoIcloud.swiftUIImage
          .resizable()
          .frame(width: 37, height: 24, alignment: .center)
        
      case .password:
        return GenImages.Images.icoLock.swiftUIImage
          .resizable()
          .frame(width: 24, height: 24, alignment: .center)
      }
    }
  }
  
  enum Popup: Identifiable {
    case settingICloud
    case enterNewPin
    case confirmPin(String)
    
    var id: String {
      String(describing: self)
    }
  }
}
