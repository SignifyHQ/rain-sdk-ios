import SwiftUI
import LFUtilities

class EnterSSNViewModel: ObservableObject {

  @Published var errorMessage: String?
  @Published var isActionAllowed: Bool = false
  
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
