import Foundation
import LFUtilities
import LFLocalizable
import Factory

public enum IdentityVerificationCodeKind {
  case ssn
  case passport
}

@MainActor
public protocol IdentityVerificationCodeViewProtocol: ObservableObject {
  var isDisableButton: Bool { get set }
  var isShowLogoutPopup: Bool { get set }
  var isLoading: Bool { get set }
  var errorMessage: String? { get set }
  var toastMessage: String? { get set }
  var ssn: String { get set }
  var passport: String { get set }
  var phoneNumber: String { get set }
  var otpCode: String { get set }
  var kind: IdentityVerificationCodeKind { get set }
  var title: String { get }
  var lastId: String { get }
  
  init(phoneNumber: String, otpCode: String, kind: IdentityVerificationCodeKind)
  func login()
  func openSupportScreen()
  func handleError(error: Error)
}
