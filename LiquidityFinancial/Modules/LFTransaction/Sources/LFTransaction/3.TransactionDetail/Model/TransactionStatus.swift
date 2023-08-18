import Foundation

public enum TransactionStatus: String, Codable {
  case pending = "PENDING"
  case completed = "COMPLETED"
  case failed = "FAILED"
  case unknown

  public init(from decoder: Decoder) throws {
    self = try TransactionStatus(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
  }

  public func localizedDescription() -> String {
    var description = ""
    switch self {
    case .completed:
      description = "Completed"
    case .pending:
      description = "Pending"
    case .failed:
      description = "Failed"

    default:
      break
    }
    return description
  }

  public var isPending: Bool {
    switch self {
    case .pending:
      return true
    case .failed, .completed, .unknown:
      return false
    }
  }
}
