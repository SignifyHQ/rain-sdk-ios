import SwiftUI
import Factory
import LFUtilities

@MainActor
public final class CommonTransactionDetailViewModel: ObservableObject {
  @LazyInjected(\.customerSupportService) var customerSupportService
  
  public init() {}
  
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }
}
