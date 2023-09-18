import Foundation
import LFUtilities
import LFLocalizable
import Factory

@MainActor
final class EnterVerificationCodeViewModel: ObservableObject {
  @LazyInjected(\.intercomService) var intercomService

  @Published var isDisableButton: Bool = true
  @Published var isShowLogoutPopup: Bool = false
  @Published var isLoading: Bool = false
  @Published var errorMessage: String?
  @Published var ssn: String = "" {
    didSet {
      checkSSNFilled()
    }
  }
  @Published var passport: String = "" {
    didSet {
      checkPassportFilled()
    }
  }

  let kind: Kind
  
  init(kind: EnterVerificationCodeViewModel.Kind) {
    self.kind = kind
  }
}

// MARK: - API
extension EnterVerificationCodeViewModel {
}

// MARK: - View Helpers
extension EnterVerificationCodeViewModel {
  var title: String {
    switch kind {
    case .ssn:
      return LFLocalizable.EnterVerificationCode.Last4SSN.screenTitle
    case .passport:
      return LFLocalizable.EnterVerificationCode.Last5Passport.screenTitle
    }
  }
  
  func openIntercom() {
    intercomService.openIntercom()
  }
}

// MARK: - Private Functions
private extension EnterVerificationCodeViewModel {
  func checkSSNFilled() {
    let ssnLength = ssn.trimWhitespacesAndNewlines().count
    isDisableButton = (ssnLength == 0) || (ssnLength != Constants.MaxCharacterLimit.ssnLength.value)
  }
  
  func checkPassportFilled() {
    let passportLength = passport.trimWhitespacesAndNewlines().count
    isDisableButton = (passportLength == 0) || (passportLength != Constants.MaxCharacterLimit.passportLength.value)
  }
}

// MARK: - Types
extension EnterVerificationCodeViewModel {
  enum Kind {
    case ssn
    case passport
  }
}
