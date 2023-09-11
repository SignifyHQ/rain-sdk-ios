import Foundation
import LFLocalizable

public enum DonationStatus: String, Codable {
  case pending = "PENDING"
  case completed = "COMPLETED"
  case unknown
  
  public init(from decoder: Decoder) throws {
    self = try DonationStatus(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
  }
  
  public func localizedDescription() -> String {
    switch self {
    case .completed:
      return LFLocalizable.TransferView.RewardsStatus.completed
    case .pending:
      return LFLocalizable.TransferView.RewardsStatus.pending
    default:
      return .empty
    }
  }
  
  public var isPending: Bool {
    self == .pending
  }
}
