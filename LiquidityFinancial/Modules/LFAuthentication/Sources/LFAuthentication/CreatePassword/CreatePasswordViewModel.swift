import Foundation
import LFUtilities
import LFLocalizable
import LFStyleGuide
import Factory
import Services

public final class CreatePasswordViewModel: ObservableObject {
  @LazyInjected(\.customerSupportService) var customerSupportService
  
  @Published var isLoading: Bool = false
  @Published var toastMessage: String?
  @Published var isActionAllowed: Bool = false {
    didSet {
      validatePassword()
    }
  }
  
  @Published var enterPassword: String = "" {
    didSet {
      isAllDataFilled()
    }
  }
  
  @Published var reenterPassword: String = "" {
    didSet {
      isAllDataFilled()
    }
  }
  
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
  }
  
  func isAllDataFilled() {
    isActionAllowed = (!enterPassword.trimWhitespacesAndNewlines().isEmpty) &&
    (!reenterPassword.trimWhitespacesAndNewlines().isEmpty)
  }
  
  func validatePassword() {
    
  }
  
  func actionContinue() {
    
  }
}
