import Foundation
import LFLocalizable
import SwiftUI
import LFStyleGuide

public enum TransactionStatus: String, Codable {
  case pending = "PENDING"
  case completed = "COMPLETED"
  case failed = "FAILED"
  case declined = "DECLINED"
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
    case .declined:
      return L10N.Common.TransferView.RewardsStatus.declined
    default:
      return .empty
    }
  }

  public var color: Color {
    switch self {
    case .completed:
      return Colors.success500.swiftUIColor
    case .pending:
      return Colors.textSecondary.swiftUIColor
    case .failed:
      return Colors.red400.swiftUIColor
    case .declined:
      return Colors.red400.swiftUIColor
    default:
      return Colors.textSecondary.swiftUIColor
    }
  }
  
  public var isPending: Bool {
    self == .pending
  }
}
