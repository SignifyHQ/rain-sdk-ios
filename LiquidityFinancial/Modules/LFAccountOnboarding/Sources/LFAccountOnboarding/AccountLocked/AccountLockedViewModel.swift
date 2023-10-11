import Foundation
import Combine
import Factory

@MainActor
final class AccountLockedViewModel: ObservableObject {
  @LazyInjected(\.customSupportService) var customSupportService
  @LazyInjected(\.onboardingFlowCoordinator) var onboardingFlowCoordinator

  init() {}
  
  func openSupportScreen() {
    customSupportService.openSupportScreen()
  }
  
  func logout() {
    onboardingFlowCoordinator.set(route: .phone)
  }
}
