import Foundation
import Combine
import Factory
import Services

@MainActor
public final class AccountLockedViewModel: ObservableObject {
  @LazyInjected(\.customerSupportService) var customerSupportService
  @LazyInjected(\.solidOnboardingFlowCoordinator) var solidOnboardingFlowCoordinator

  public init() {}
  
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }
  
  func logout() {
    solidOnboardingFlowCoordinator.set(route: .phone)
  }
}
