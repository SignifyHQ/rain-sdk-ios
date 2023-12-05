import Foundation

public enum TextRestriction {
  case none
  case alphabets
  case numbers
  case alphanumeric
  case alphabetsAndComma
  case decimal
  case password

  public var allowedInput: String {
    switch self {
    case .none:
      return ""
    case .alphabets:
      return "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ "
    case .numbers:
      return "0123456789"
    case .alphanumeric:
      return "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    case .alphabetsAndComma:
      return "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ, "
    case .decimal:
      return "^[0-9]*((\\.|,)[0-9]{0,2})?$"
    case .password:
      return "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-_=+[]{}|;:'\",.<>/?`~"
    }
  }
}
