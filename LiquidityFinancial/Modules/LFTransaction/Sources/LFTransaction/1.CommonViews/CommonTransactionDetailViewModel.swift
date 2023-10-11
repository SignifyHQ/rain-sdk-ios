import SwiftUI
import Factory
import LFUtilities

@MainActor
public final class CommonTransactionDetailViewModel: ObservableObject {
  @LazyInjected(\.customSupportService) var customSupportService
  
  public init() {}
  
  func openSupportScreen() {
    customSupportService.openSupportScreen()
  }
}
