import Foundation
import LFLocalizable

public enum TransactionStatus: String, Codable {
  case pending = "PENDING"
  case completed = "COMPLETED"
  case failed = "FAILED"
  case unknown

  public init(from decoder: Decoder) throws {
    self = try TransactionStatus(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
  }

  public func localizedDescription() -> String {
    switch self {
    case .completed:
      return L10N.Common.TransferView.RewardsStatus.completed
    case .pending:
      return L10N.Common.TransferView.RewardsStatus.pending
    case .failed:
      return L10N.Common.TransferView.RewardsStatus.failed
    default:
      return .empty
    }
  }

  public var isPending: Bool {
    self == .pending
  }
}
