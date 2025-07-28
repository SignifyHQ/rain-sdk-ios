import Foundation

public enum TextRestriction {
  case none
  case alphabets
  case numbers
  case alphanumeric
  case alphabetsAndComma
  case decimal
  case password
  case asciiPrintable

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
    case .asciiPrintable:
      return (32...126).compactMap { UnicodeScalar($0) }.map(String.init).joined()
    }
  }
}
