import SwiftUI
import Factory
import NetSpendData
import OnboardingData
import LFUtilities
import LFServices
// MARK: - SetupWalletViewModel

class SetupWalletViewModel: ObservableObject {
  
  @Published var showIndicator = false
  @Published var toastMessage: String?
  @Published var selection: Int?
  @Published var isTermsAgreed = false
  
  @LazyInjected(\.onboardingRepository) var onboardingRepository
  @LazyInjected(\.onboardingFlowCoordinator) var onboardingFlowCoordinator
  @LazyInjected(\.intercomService) var intercomService
  
  func createZeroHashAccount() {
    Task { @MainActor in
      defer { showIndicator = false }
      showIndicator = true
      do {
        let zeroHashAccount = try await onboardingRepository.createZeroHashAccount()
        onboardingFlowCoordinator.set(route: .dashboard)
        log.debug(zeroHashAccount)
      } catch {
        log.error(error.localizedDescription)
      }
    }
  }
  
  func openIntercom() {
    intercomService.openIntercom()
  }
}
