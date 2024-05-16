import Foundation
  
enum CardStatus: String {
  case active
  case closed
  case disabled
  case unactivated
  
  init?(rawValue: String) {
    switch rawValue {
    case "active":
      self = .active
    case "closed":
      self = .closed
    case "canceled":
      self = .closed
    case "locked":
      self = .disabled
    case "disabled":
      self = .disabled
    case "inactive":
      self = .disabled
    case "unactivated":
      self = .unactivated
    case "pendingActivation":
      self = .unactivated
    case "not_activated":
      self = .unactivated
    default:
      self = .unactivated
    }
  }
}
