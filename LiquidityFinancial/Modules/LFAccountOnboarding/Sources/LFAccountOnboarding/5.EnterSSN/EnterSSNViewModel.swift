import SwiftUI
import LFUtilities
import Factory
import OnboardingData
import AccountData
import LFServices

@MainActor
class EnterSSNViewModel: ObservableObject {
  
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.customSupportService) var customSupportService
  @LazyInjected(\.analyticsService) var analyticsService
  
  @Published var errorMessage: String?
  @Published var isActionAllowed: Bool = false {
    didSet {
      guard isActionAllowed else { return }
      accountDataManager.update(ssn: ssn)
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
  
  func openSupportScreen() {
    customSupportService.openSupportScreen()
  }
  
  func magicFillAccount() {
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
