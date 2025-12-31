import Factory
import Foundation

@MainActor
public final class WalkthroughViewModel: ObservableObject {
  @LazyInjected(\.customerSupportService) var customerSupportService
  
  @Published var navigation: Navigation?
  
  @Published var step: Int = 1
}

// MARK: - Handling Interations
extension WalkthroughViewModel {
  func onSupportButtonTap() {
    customerSupportService.openSupportScreen()
  }
  
  func onNextButtonTap() {
    step += 1
  }
  
  func onSignUpButtonTap(
    with authMethod: AuthMethod
  ) {
    navigation = .countryOfResidence(authMethod: authMethod)
  }
}

// MARK: - Private Enums
extension WalkthroughViewModel {
  enum Navigation {
    case countryOfResidence(authMethod: AuthMethod)
  }
  
  enum AuthMethod {
    case phone
    case email
  }
}
