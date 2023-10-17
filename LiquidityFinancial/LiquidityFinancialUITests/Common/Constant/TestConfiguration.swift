import Foundation

// MARK: - UserAccount
enum TestConfiguration {
  enum UserAccount {
    case validAccount
    case lockedAccount
    
    var informations: (phoneNumber: String, ssn: String) {
      switch self {
      case .validAccount:
        return ("8502074306", "2987")
      case .lockedAccount:
        return ("2058583181", "2897")
      }
    }
  }
}
