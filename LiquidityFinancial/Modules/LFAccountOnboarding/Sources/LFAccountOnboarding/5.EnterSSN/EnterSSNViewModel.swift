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

  #if DEBUG
  var countGenerateUser: Int = 0
  #endif
  
  func openIntercom() {
      // TODO: Will be implemented later
      // intercomService.openIntercom()
    magicFillAccount()
  }
  
  private func magicFillAccount() {
#if DEBUG
    countGenerateUser += 1
    if countGenerateUser >= 3 {
      let userMock = UserMockManager.mockUser(countTap: countGenerateUser)
      ssn = userMock.ssn
      if countGenerateUser >= 5 { countGenerateUser = 0 }
    }
#endif
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
