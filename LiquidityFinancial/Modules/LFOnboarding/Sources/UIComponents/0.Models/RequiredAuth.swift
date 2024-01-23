import Foundation

public enum RequiredAuth: String {
  case unknow
  case otp = "OTP"
  case ssn = "LAST_4_SSN"
  case passport = "LAST_5_PASSPORT"
  case password = "PASSWORD"
  case mfa = "MFA"
}

public extension String {
  var reformatPhone: String {
    self
      .replace(string: " ", replacement: "")
      .replace(string: "(", replacement: "")
      .replace(string: ")", replacement: "")
      .replace(string: "-", replacement: "")
      .trimWhitespacesAndNewlines()
  }
}
