import SwiftUI
import LFUtilities
import Factory
import OnboardingData
import AccountData
import LFServices

public enum EnterSSNNavigation {
  case address(AnyView)
  case enterPassport(AnyView)
}

@MainActor
public final class EnterSSNViewModel: ObservableObject {
  
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.customerSupportService) var customerSupportService
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
  
  var shouldEnablePassport: Bool {
    LFUtilities.charityEnabled
  }
  
  let isVerifySSN: Bool
  
  public init(isVerifySSN: Bool) {
    self.isVerifySSN = isVerifySSN
  }
  
  func openSupportScreen() {
    customerSupportService.openSupportScreen()
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
