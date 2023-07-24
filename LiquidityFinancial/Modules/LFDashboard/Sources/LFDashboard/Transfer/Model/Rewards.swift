import Foundation
import LFLocalizable
import LFStyleGuide
import SwiftUI

struct Rewards {
  let type: UserRewardType
  let amount: Double
  let roundUpAmount: Double?
  let currency: String
  let status: Status
  let earnedAt: Date?
  let completedAt: Date?
}

// MARK: - Codable

extension Rewards: Codable {
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    type = try container.decode(UserRewardType.self, forKey: .type)
    let amountStr = try container.decode(String.self, forKey: .amount)
    amount = amountStr.asDouble ?? 0
    roundUpAmount = try (container.decodeIfPresent(String.self, forKey: .roundUpAmount))?.asDouble
    currency = try container.decode(String.self, forKey: .currency)
    status = try container.decode(Status.self, forKey: .status)
    if let str = try container.decodeIfPresent(String.self, forKey: .earnedAt), let date = DateFormatter.server.date(from: str) {
      earnedAt = date
    } else {
      earnedAt = nil
    }
    if let str = try container.decodeIfPresent(String.self, forKey: .completedAt), let date = DateFormatter.server.date(from: str) {
      completedAt = date
    } else {
      completedAt = nil
    }
  }
}

// MARK: - Status

extension Rewards {
  enum Status: String, Codable {
    case pending
    case completed

    var display: String {
      switch self {
      case .pending:
        return LFLocalizable.TransferView.RewardsStatus.pending
      case .completed:
        return LFLocalizable.TransferView.RewardsStatus.completed
      }
    }

    var image: Image {
      switch self {
      case .pending:
        return GenImages.Images.statusPending.swiftUIImage
      case .completed:
        return GenImages.Images.statusCompleted.swiftUIImage
      }
    }
  }
}
