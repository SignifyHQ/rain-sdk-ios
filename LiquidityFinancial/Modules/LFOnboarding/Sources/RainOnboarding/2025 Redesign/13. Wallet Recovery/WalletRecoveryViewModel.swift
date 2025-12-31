import BaseOnboarding
import Combine
import Factory
import Foundation
import LFLocalizable
import LFStyleGuide
import LFUtilities
import PortalSwift
import PortalData
import PortalDomain
import Services

@MainActor
public final class WalletRecoveryViewModel: ObservableObject {
  @LazyInjected(\.customerSupportService) var customerSupportService
  
  @LazyInjected(\.onboardingCoordinator) var onboardingCoordinator
  
  @LazyInjected(\.portalRepository) var portalRepository
  
  @Published var navigation: OnboardingNavigation?
  
  @Published var isEnterPinPresented = false
  
  @Published var isWalletRecoveredSuccessfully: Bool?
  
  @Published var isCloudRecoveryRunning: Bool = false
  @Published var isPinRecoveryRunning: Bool = false
  // In this case, `isLoading` is only used for the initial auto recovery
  @Published var isLoading: Bool = true
  @Published var currentToast: ToastData? = nil
  
  @Published var pin: String = .empty
  
  lazy var recoverWalletUseCase: RecoverWalletUseCaseProtocol = {
    RecoverWalletUseCase(repository: portalRepository)
  }()
  
  var isContinueButtonEnabled: Bool {
    return pin.count == 4
  }
  
  init() {}
  
  func onAppear() {
    // Attempt to recover the wallet automatially from cloud at first
    if isLoading {
      onRecoverWithCloudButtonTap()
    }
  }
}

// MARK: - Binding Observables
extension WalletRecoveryViewModel {}

// MARK: - Handling UI/UX Logic
extension WalletRecoveryViewModel {}

// MARK: - Handling Interations
extension WalletRecoveryViewModel {
  func onSupportButtonTap() {
    customerSupportService.openSupportScreen()
  }
  
  func onRecoverWithCloudButtonTap() {
    Task {
      defer {
        isCloudRecoveryRunning = false
      }
      
      isCloudRecoveryRunning = true
      
      do {
        // Attempt wallet recovery with iCloud
        try await performCloudPortalWalletRecovery()
        // If it is the automatic cloud recovery, take the user further in the flow
        if isLoading {
          navigation = try await onboardingCoordinator.getOnboardingNavigation()
          // Otherwise, show a success sheet and wait for action
        } else {
          isWalletRecoveredSuccessfully = true
        }
      } catch {
        isLoading = false
        
        var shouldPresentFailureSheet = false
        // If the error indicates that no wallet backup share was found
        // on device, show bottom sheet with failed status. Otherwise,
        // just show the error toast
        if let portalError = error as? LFPortalError {
          switch portalError {
          case .iCloudAccountUnavailable, .cipherBlockCreationFailed:
            shouldPresentFailureSheet = true
          default:
            break
          }
        }
        
        if let errorCode = error.asErrorObject?.code {
          switch errorCode {
          case Constants.ErrorCode.portalBackupShareNotFound.rawValue:
            shouldPresentFailureSheet = true
          default:
            break
          }
        }
        
        if shouldPresentFailureSheet {
          isWalletRecoveredSuccessfully = false
        } else {
          currentToast = ToastData(
            type: .error,
            body: error.userFriendlyMessage
          )
        }
      }
    }
  }
  
  func onRecoverWithPinButtonTap() {
    isWalletRecoveredSuccessfully = nil
    
    isPinRecoveryRunning = true
    isEnterPinPresented = true
  }
  
  func onConfirmPinButtonTap() {
    Task {
      defer {
        isPinRecoveryRunning = false
      }
      
      isEnterPinPresented = false
      
      do {
        // Attempt wallet recovery with PIN
        try await performPinPortalWalletRecovery()
        // Show the success bottom sheet if the recovery is successful
        isWalletRecoveredSuccessfully = true
      } catch {
        var errorMessage = error.userFriendlyMessage
        // Check if the error is `decryptFailed` which potentially means
        // that a wrong PIN was used. If so, present a corresponding message
        if let portalMpcError = error as? LFPortalError {
          switch portalMpcError {
          case .decryptFailed:
            errorMessage = "Failed to recover your wallet. Please check your PIN and try again."
          default:
            break
          }
        }
        // In all other cases, show error message
        currentToast = ToastData(
          type: .error,
          body: errorMessage
        )
      }
    }
  }
  
  func onContinueButtonTap() {
    Task {
      defer {
        isLoading = false
      }
      
      isWalletRecoveredSuccessfully = nil
      isLoading = true
      
      do {
        navigation = try await onboardingCoordinator.getOnboardingNavigation()
      } catch {
        currentToast = ToastData(
          type: .error,
          body: error.userFriendlyMessage
        )
      }
    }
  }
}

//MARK: - Handling API Calls
extension WalletRecoveryViewModel {
  private func performCloudPortalWalletRecovery() async throws {
    try await recoverWalletUseCase.execute(backupMethod: .iCloud, password: nil)
  }
  
  private func performPinPortalWalletRecovery() async throws {
    try await recoverWalletUseCase.execute(backupMethod: .Password, password: pin)
  }
}

// MARK: - Helper Functions
extension WalletRecoveryViewModel {}

// MARK: - Private Enums
extension WalletRecoveryViewModel {}
