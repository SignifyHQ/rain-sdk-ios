import Foundation
import Combine
import Factory
import Services
import BaseOnboarding

@MainActor
final class AccountLockedViewModel: AccountLockedViewModelProtocol {
  @LazyInjected(\.customerSupportService) var customerSupportService
  @LazyInjected(\.solidOnboardingFlowCoordinator) var solidOnboardingFlowCoordinator

  init() {}
  
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }
  
  func logout() {
    solidOnboardingFlowCoordinator.set(route: .phone)
  }
}
