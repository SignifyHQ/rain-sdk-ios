import SwiftUI
import LFUtilities

class EnterSSNViewModel: ObservableObject {
  init(isVerifySSN: Bool) {
    self.isVerifySSN = isVerifySSN
  }

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

  @Published var errorMessage: String?
  @Published var isActionAllowed: Bool = false

  let isVerifySSN: Bool

  @Published var ssn: String = "" {
    didSet {
      isAllDataFilled()
    }
  }
}


private extension EnterSSNViewModel {
  func isAllDataFilled() {
    let ssnLength = isVerifySSN ? Constants.MaxCharacterLimit.fullSSNLength.value : Constants.MaxCharacterLimit.ssnLength.value
    isActionAllowed = (!ssn.trimWhitespacesAndNewlines().isEmpty) && (ssn.trimWhitespacesAndNewlines().count == ssnLength)
  }
}
