import Foundation
import SwiftUI
import Factory
import LFUtilities
import Combine
import Services
import PortalData
import PortalDomain
import PortalSwift

@MainActor
final class ICloudBackupNotFoundViewModel: ObservableObject {
  @LazyInjected(\.portalRepository) var portalRepository
  @LazyInjected(\.customerSupportService) var customerSupportService

  @Published var isLoading: Bool = false
  @Published var hasPasswordBackup: Bool = false
  @Published var toastMessage: String?
  @Published var navigation: Navigation?
  
  lazy var getBackupMethodsUseCase: GetBackupMethodsUseCaseProtocol = {
    GetBackupMethodsUseCase(repository: portalRepository)
  }()
  
  init() {
    fetchBackupMethods()
  }
}

// MARK: - API Handle
extension ICloudBackupNotFoundViewModel {
  func fetchBackupMethods() {
    Task {
      defer { isLoading = false }
      isLoading = true
      
      do {
        let response = try await getBackupMethodsUseCase.execute()
        let backupMethods = response.backupMethods.map {
          BackupMethods(rawValue: $0)
        }
        hasPasswordBackup = backupMethods.contains(.Password)
      } catch {
        log.error(error.userFriendlyMessage)
        toastMessage = error.userFriendlyMessage
      }
    }
  }
}
// MARK: - View Handle
extension ICloudBackupNotFoundViewModel {
  func contactSupportButtonTapped() {
    customerSupportService.openSupportScreen()
  }
  
  func tryAnotherMethodButtonTapped() {
    navigation = .recoverByPinCode
  }
}

// MARK: - Types
extension ICloudBackupNotFoundViewModel {
  enum Navigation {
    case recoverByPinCode
  }
}
