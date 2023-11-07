import Factory
import Foundation

class PatriotActViewModel: ObservableObject {
  
  @LazyInjected(\.customerSupportService) var customerSupportService
  
  @Published var shouldContinue: Bool = false
  @Published var isNoticeAccepted: Bool = false
  
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }
}

