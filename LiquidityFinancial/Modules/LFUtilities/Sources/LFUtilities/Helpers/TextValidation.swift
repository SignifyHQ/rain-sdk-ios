import Foundation

public enum TextValidation {
  case containsSpecialCharacter
  case containsSpecialCharacterExceptSpace
  case containsLowerCase
  case containsUpperCase
  
  public var predicate: NSPredicate {
    switch self {
    case .containsSpecialCharacter:
      return NSPredicate(format: "SELF MATCHES %@", ".*[^A-Za-z0-9].*")
    case .containsSpecialCharacterExceptSpace:
      return NSPredicate(format: "SELF MATCHES %@", ".*[^A-Za-z0-9 ].*")
    case .containsLowerCase:
      return NSPredicate(format: "SELF MATCHES %@", ".*[a-z].*")
    case .containsUpperCase:
      return NSPredicate(format: "SELF MATCHES %@", ".*[A-Z].*")
    }
  }
}
