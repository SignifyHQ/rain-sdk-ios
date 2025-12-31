import Foundation
import SwiftUI
import Combine
import LFLocalizable
import PortalDomain
import Factory
import LFStyleGuide
import PortalSwift
import Services

@MainActor
final class ICloudBackupViewModel: ObservableObject {
  @LazyInjected(\.portalRepository) var portalRepository
  
  private lazy var backupWalletUseCase: BackupWalletUseCaseProtocol = {
    BackupWalletUseCase(repository: portalRepository)
  }()
  
  @Published var state: State = .start
  @Published var toastData: ToastData?
  @Published var popup: Popup?
}

// MARK: Handle Interactions
extension ICloudBackupViewModel {
  func backupPortalWalletWithIcloud(completion: (() -> Void)?) {
    Task {
      defer {
        state = .completed
      }
      
      state = .inProgress
      
      do {
        try await backupWalletUseCase.execute(backupMethod: .iCloud, password: nil)
        completion?()
      } catch {
        handlePortalError(error: error)
      }
    }
  }
  
  func handlePortalError(error: Error) {
    guard let portalError = error as? LFPortalError else {
      toastData = .init(type: .error, title: error.localizedDescription)
      return
    }
    
    switch portalError {
    case .iCloudAccountUnavailable:
      toastData = .init(type: .error, title: L10N.Common.WalletBackup.SignInToIcloud.message)
    case .customError(let message):
      toastData = .init(type: .error, title: message)
    default:
      toastData = .init(type: .error, title: error.localizedDescription)
    }
  }
}

// MARK: Enums
extension ICloudBackupViewModel {
  enum State: Equatable {
    case start
    case inProgress
    case completed
    
    var description: String {
      switch self {
      case .start:
        return L10N.Common.WalletBackup.UpdateBackup.StartContent.title
      case .inProgress:
        return L10N.Common.WalletBackup.UpdateBackup.InProgressContent.title
      case .completed:
        return L10N.Common.WalletBackup.UpdateBackup.SuccessContent.title
      }
    }
    
    var buttonTitle: String {
      switch self {
      case .start, .inProgress:
        return L10N.Common.Common.Continue.Button.title
      case .completed:
        return L10N.Common.Common.Close.Button.title
      }
    }
  }
}
