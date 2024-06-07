import Foundation
import SwiftUI
import Factory
import LFUtilities
import LFLocalizable
import Combine
import Services
import PortalData
import PortalDomain
import PortalSwift

@MainActor
final class RecoverWalletViewModel: ObservableObject {
  @LazyInjected(\.rainOnboardingFlowCoordinator) var onboardingFlowCoordinator
  @LazyInjected(\.portalRepository) var portalRepository
  @LazyInjected(\.customerSupportService) var customerSupportService

  @Published var isLoading: Bool = false
  // TODO: - Will handle in another ticket
  @Published var panLast4: String = "2512"
  @Published var toastMessage: String?

  @Published var navigation: Navigation?
  @Published var popup: Popup?
  
  lazy var recoverWalletUseCase: RecoverWalletUseCaseProtocol = {
    RecoverWalletUseCase(repository: portalRepository)
  }()
  
  let recoverMethod: BackupMethods
  
  init(recoverMethod: BackupMethods) {
    self.recoverMethod = recoverMethod
  }
}

// MARK: - API Handler
extension RecoverWalletViewModel {
  func recoverWalletByICloud() {
    Task {
      defer { isLoading = false }
      isLoading = true
      
      do {
        try await recoverWalletUseCase.execute(backupMethod: .iCloud, password: nil)
        
        popup = .recoverySuccessfully
      } catch {
        handleError(error: error)
      }
    }
  }
}

// MARK: - View Handler
extension RecoverWalletViewModel {
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }
  
  func startRecoveryButtonTapped() {
    switch recoverMethod {
    case .iCloud:
      recoverWalletByICloud()
    case .Password:
      navigation = .recoverByPinCode
    default:
      break
    }
  }
  
  var description: String {
    switch recoverMethod {
    case .iCloud:
      return L10N.Common.RecoverWallet.description("iCloud")
    case .Password:
      return L10N.Common.RecoverWallet.description("PIN")
    default:
      return .empty
    }
  }
  
  func recoverySuccessfullyPrimaryButtonTapped() {
    popup = nil
    onboardingFlowCoordinator.set(route: .dashboard)
  }
}

// MARK: - Private Functions
private extension RecoverWalletViewModel {
  func handleError(error: Error) {
    do {
      try handleBackendError(error: error)
    } catch {
      handlePortalError(error: error)
    }
  }
  
  func handlePortalError(error: Error) {
    guard let portalError = error as? LFPortalError else {
      toastMessage = error.userFriendlyMessage
      log.error(error.userFriendlyMessage)
      return
    }
    
    switch portalError {
    case .iCloudAccountUnavailable:
      navigation = .iCloudNotFound
    case .customError(let message):
      toastMessage = message
    default:
      toastMessage = portalError.localizedDescription
    }
    
    log.error(toastMessage ?? portalError.localizedDescription)
  }
  
  func handleBackendError(error: Error) throws {
    guard let errorCode = error.asErrorObject?.code else {
      throw error
    }
    
    switch errorCode {
    case Constants.ErrorCode.portalBackupShareNotFound.rawValue:
      navigation = .iCloudNotFound
    default:
      throw error
    }
  }
}

// MARK: - Types
extension RecoverWalletViewModel {
  enum Navigation {
    case iCloudNotFound
    case recoverByPinCode
  }
  
  enum Popup {
    case recoverySuccessfully
  }
}
