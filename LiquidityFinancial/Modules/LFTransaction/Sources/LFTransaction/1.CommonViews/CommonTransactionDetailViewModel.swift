import SwiftUI
import Factory
import LFUtilities

@MainActor
public final class CommonTransactionDetailViewModel: ObservableObject {
  @LazyInjected(\.intercomService) var intercomService
  
  public init() {}
  
  func openIntercom() {
    intercomService.openIntercom()
  }
}
