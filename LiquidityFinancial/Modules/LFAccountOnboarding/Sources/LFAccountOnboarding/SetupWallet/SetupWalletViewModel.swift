import SwiftUI
import Factory
import NetSpendData
import OnboardingData
import LFUtilities

// MARK: - SetupWalletViewModel

class SetupWalletViewModel: ObservableObject {
  
  @Published var showIndicator = false
  @Published var toastMessage: String?
  @Published var selection: Int?
  @Published var isTermsAgreed = false
  
  @LazyInjected(\.netspendDataManager) var netspendDataManager
  @LazyInjected(\.userDataManager) var userDataManager
  @LazyInjected(\.netspendRepository) var netspendRepository
  @LazyInjected(\.onboardingRepository) var onboardingRepository
  @LazyInjected(\.onboardingFlowCoordinator) var onboardingFlowCoordinator
  
  func createZeroHashAccount() {
    Task { @MainActor in
      defer { showIndicator = false }
      showIndicator = true
      do {
        let zeroHashAccount = try await onboardingRepository.createZeroHashAccount()
        onboardingFlowCoordinator.set(route: .dashboard)
      } catch {
        log.error(error.localizedDescription)
      }
    }
  }
  
}
