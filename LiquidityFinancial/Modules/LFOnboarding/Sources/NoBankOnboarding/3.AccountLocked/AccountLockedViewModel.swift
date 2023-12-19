import Foundation
import Combine
import Factory
import Services
import BaseOnboarding

@MainActor
final class AccountLockedViewModel: AccountLockedViewModelProtocol {
  @LazyInjected(\.customerSupportService) var customerSupportService
  @LazyInjected(\.noBankOnboardingFlowCoordinator) var onboardingFlowCoordinator

  init() {}
  
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }
  
  func logout() {
    onboardingFlowCoordinator.set(route: .phone)
  }
}
