import BaseOnboarding
import Combine
import Factory
import Foundation
import LFLocalizable
import LFStyleGuide
import LFUtilities
import PortalData
import PortalDomain

@MainActor
public final class SetRecoveryPinViewModel: ObservableObject {
  @LazyInjected(\.customerSupportService) var customerSupportService
  
  @LazyInjected(\.onboardingCoordinator) var onboardingCoordinator
  
  @LazyInjected(\.portalRepository) var portalRepository
  
  @Published var navigation: OnboardingNavigation?
  
  @Published var pin: String = .empty
  @Published var confirmPin: String = .empty
  
  @Published var isConfirmPinPresented: Bool = false
  
  @Published var isLoading: Bool = false
  @Published var currentToast: ToastData? = nil
  
  lazy var backupWalletUseCase: BackupWalletUseCaseProtocol = {
    BackupWalletUseCase(repository: portalRepository)
  }()
  
  var isContinueButtonEnabled: Bool {
    pin.count == 4
  }
  
  var isConfirmButtonEnabled: Bool {
    // Only enable the Continue button if pins match
    confirmPin == pin
  }
  
  var isPinMismatchDetected: Bool {
    // Show pin mistatch error if the 4 digits are entered and pins don't match
    confirmPin.count == 4 && pin != confirmPin
  }
  
  init() {}
}

// MARK: - Binding Observables
extension SetRecoveryPinViewModel {}

// MARK: - Handling UI/UX Logic
extension SetRecoveryPinViewModel {}

// MARK: - Handling Interations
extension SetRecoveryPinViewModel {
  func onSupportButtonTap() {
    customerSupportService.openSupportScreen()
  }
  
  func onContinueButtonTap() {
    isConfirmPinPresented = true
  }
  
  func onConfirmPinButtonTap() {
    Task {
      defer {
        isLoading = false
      }
      // Hide the bottom sheet and initiate the PIN backup process
      isConfirmPinPresented = false
      isLoading = true
      
      do {
        try await performPinPortalWalletBackup()
        // Present success toast
        currentToast = ToastData(
          type: .success,
          title: "Success",
          body: "PIN created successfully!"
        )
        // Give a second for the toast to stay on before navigating to the next steps
        try await Task.sleep(for: .seconds(1))
        // Navigate to next onboarding step on success
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

// MARK: - API Calls
extension SetRecoveryPinViewModel {
  private func performPinPortalWalletBackup(
  ) async throws {
    try await backupWalletUseCase.execute(backupMethod: .Password, password: pin)
    log.debug("Portal wallet PIN backup share saved successfully")
  }
}

// MARK: - Helper Functions
extension SetRecoveryPinViewModel {}

// MARK: - Private Enums
extension SetRecoveryPinViewModel {}
