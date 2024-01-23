import Foundation
import Combine
import Factory
import Services

@MainActor
final class AccountLockedViewModel: ObservableObject {
  @LazyInjected(\.customerSupportService) var customerSupportService
  @LazyInjected(\.nsOnboardingFlowCoordinator) var onboardingFlowCoordinator

  init() {}
  
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }
  
  func logout() {
    onboardingFlowCoordinator.set(route: .phone)
  }
}
