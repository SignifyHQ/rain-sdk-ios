import Factory
import Foundation

class YourAccountViewModel: ObservableObject {
  
  @LazyInjected(\.customerSupportService) var customerSupportService
  
  @Published var shouldContinue: Bool = false
  @Published var isEsignatureAccepted: Bool = false
  @Published var isTermsPrivacyAccepted: Bool = false
  
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }
}
