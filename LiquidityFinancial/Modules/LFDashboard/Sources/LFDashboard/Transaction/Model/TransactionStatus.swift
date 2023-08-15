import Foundation

enum TransactionStatus: String, Codable {
  case notStarted = "NOTSTARTED"
  case completed = "COMPLETED"
  case inProgress = "INPROGRESS"
  case pending = "PENDING"
  case settled = "SETTLED"
  case unknown = "UNKNOW"

  init(from decoder: Decoder) throws {
    self = try TransactionStatus(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
  }

  func localizedDescription() -> String {
    var description = ""
    switch self {
    case .notStarted:
      description = "Not Started"
    case .completed:
      description = "Completed"
    case .inProgress:
      description = "In Progress"
    case .pending:
      description = "Pending"
    case .settled:
      description = "Settled"

    default:
      break
    }
    return description
  }

  var isPending: Bool {
    switch self {
    case .notStarted, .pending, .inProgress:
      return true
    case .settled, .completed, .unknown:
      return false
    }
  }
}
