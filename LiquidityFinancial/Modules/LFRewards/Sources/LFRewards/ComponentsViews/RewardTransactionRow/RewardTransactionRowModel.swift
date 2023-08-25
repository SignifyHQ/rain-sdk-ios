import Foundation
import LFStyleGuide

public struct RewardTransactionRowModel: Identifiable, Equatable {
  public var id: String
  public var fundraiserId, donationId, userId, userName: String?
  public var amount: Double?
  public var createdAt: String?
  
  public init(id: String, fundraiserId: String?, donationId: String?, userId: String?, userName: String?, amount: Double?, createdAt: String?) {
    self.id = id
    self.fundraiserId = fundraiserId
    self.donationId = donationId
    self.userId = userId
    self.userName = userName
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
  }
  
  public var assetName: String {
    GenImages.Images.Transactions.txDonation.name
  }
  public var titleDisplay: String {
    userName ?? ""
  }
  public var subtitle: String {
    transactionDateInLocalZone()
  }
  public var ammountFormatted: String {
    amount?.formattedAmount(minFractionDigits: 3, maxFractionDigits: 3) ?? "$0"
  }
  
  func transactionDateInLocalZone(includeYear: Bool = false) -> String {
    createdAt?.serverToTransactionDisplay(includeYear: includeYear) ?? ""
  }
}
