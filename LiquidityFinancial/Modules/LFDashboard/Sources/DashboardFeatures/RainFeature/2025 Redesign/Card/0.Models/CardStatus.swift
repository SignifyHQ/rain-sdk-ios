import Foundation
  
enum CardStatus: String {
  case active
  case closed
  case disabled
  case unactivated
  case pending
  case canceled
  
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
    case "pending":
      self = .pending
    case "cancelled":
      self = .canceled
    default:
      self = .unactivated
    }
  }
}
