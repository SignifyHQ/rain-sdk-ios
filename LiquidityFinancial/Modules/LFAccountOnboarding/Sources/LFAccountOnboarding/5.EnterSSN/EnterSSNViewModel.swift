import SwiftUI
import LFUtilities
import Factory
import OnboardingData

@MainActor
class EnterSSNViewModel: ObservableObject {
  
  @Injected(\Container.userDataManager) var userDataManager
  
  @Published var errorMessage: String?
  @Published var isActionAllowed: Bool = false {
    didSet {
      guard isActionAllowed else { return }
      userDataManager.update(ssn: ssn)
    }
  }
  @Published var ssn: String = "" {
    didSet {
      isAllDataFilled()
    }
  }
  
  let isVerifySSN: Bool
  
  init(isVerifySSN: Bool) {
    self.isVerifySSN = isVerifySSN
  }

  func openIntercom() {
      // TODO: Will be implemented later
      // intercomService.openIntercom()
  }
}


private extension EnterSSNViewModel {
  func isAllDataFilled() {
    let ssnLength = isVerifySSN ? Constants.MaxCharacterLimit.fullSSNLength.value : Constants.MaxCharacterLimit.ssnLength.value
    isActionAllowed = (!ssn.trimWhitespacesAndNewlines().isEmpty) && (ssn.trimWhitespacesAndNewlines().count == ssnLength)
  }
}

private extension EnterSSNViewModel {
  enum SSNInfoError: Error, LocalizedError {
    case invalidSSN
    
      /// API related custom error title
    var errorDescription: String? {
      switch self {
      case .invalidSSN:
        return "Invalid SSN"
      }
    }
  }
}
