import Foundation
import Combine
import Factory
import Services

@MainActor
public final class AccountLockedViewModel: ObservableObject {
  @LazyInjected(\.customerSupportService) var customerSupportService
  
  private let setRouteToPhoneNumber: (() -> Void)?
  
  public init(setRouteToPhoneNumber: (() -> Void)?) {
    self.setRouteToPhoneNumber = setRouteToPhoneNumber
  }
}

// MARK: - View Handler
extension AccountLockedViewModel {
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }
  
  func logout() {
    setRouteToPhoneNumber?()
  }
}
