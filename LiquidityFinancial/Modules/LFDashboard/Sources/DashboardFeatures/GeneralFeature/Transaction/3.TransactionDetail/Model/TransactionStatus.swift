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
      return LFLocalizable.TransferView.RewardsStatus.completed
    case .pending:
      return LFLocalizable.TransferView.RewardsStatus.pending
    case .failed:
      return LFLocalizable.TransferView.RewardsStatus.failed
    default:
      return .empty
    }
  }

  public var isPending: Bool {
    self == .pending
  }
}
