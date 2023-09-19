import Foundation
import Combine
import Factory

@MainActor
final class AccountLockedViewModel: ObservableObject {
  @LazyInjected(\.intercomService) var intercomService
  @LazyInjected(\.onboardingFlowCoordinator) var onboardingFlowCoordinator

  init() {}
  
  func openIntercom() {
    intercomService.openIntercom()
  }
  
  func logout() {
    onboardingFlowCoordinator.set(route: .phone)
  }
}
