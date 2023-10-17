import Foundation

public enum RequiredAuth: String {
  case unknow
  case otp = "OTP"
  case ssn = "LAST_4_SSN"
  case passport = "LAST_5_PASSPORT"
}
