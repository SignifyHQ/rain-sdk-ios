import Foundation
import LFStyleGuide
import LFUtilities
import LFLocalizable

public struct RewardTransactionRowModel: Identifiable, Equatable {
  public var id: String
  public var title, fundraiserId, donationId, userId, userName: String?
  public var amount: Double?
  public var stickerUrl: String?
  public var status: RewardStatus
  public var createdAt: String?
  
  public init(
    id: String,
    title: String?,
    fundraiserId: String?,
    donationId: String?,
    userId: String?,
    userName: String?,
    amount: Double?,
    stickerUrl: String?,
    status: String?,
    createdAt: String?
  ) {
    self.id = id
    self.title = title
    self.fundraiserId = fundraiserId
    self.donationId = donationId
    self.userId = userId
    self.userName = userName
    self.status = RewardStatus(rawValue: status ?? .empty) ?? .unknown
    self.stickerUrl = stickerUrl
    self.amount = amount
    self.createdAt = createdAt
  }
  
  public init(latestDonation: LFLatestDonationModel) {
    self.id = latestDonation.id
    self.fundraiserId = latestDonation.fundraiserId
    self.userId = latestDonation.userId
    self.userName = latestDonation.userName
    self.amount = latestDonation.amount
    self.createdAt = latestDonation.createdAt
    self.donationId = nil
    self.title = latestDonation.titleDisplay
    self.stickerUrl = nil
    self.status = .unknown
  }
  
  public var assetName: String {
    GenImages.Images.Transactions.txDonation.name
  }
  public var titleDisplay: String {
    title ?? ""
  }
  public var subtitle: String {
    if status.isPending {
      return status.localizedDescription()
    } else {
      return createdAt?.serverToTransactionDisplay(includeYear: true) ?? .empty
    }
  }
  public var ammountFormatted: String {
    amount?.formattedAmount(
      prefix: Constants.CurrencyUnit.usd.symbol,
      minFractionDigits: Constants.FractionDigitsLimit.fiat.minFractionDigits
    ) ?? "$0.00"
  }
}

// MARK: - Types
extension RewardTransactionRowModel {
  public enum RewardStatus: String, Codable {
    case pending = "PENDING"
    case completed = "COMPLETED"
    case unknown
    
    public init(from decoder: Decoder) throws {
      self = try RewardStatus(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
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
}
