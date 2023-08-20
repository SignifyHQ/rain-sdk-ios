import Foundation

public struct DonationReceipt {
  public let id: String
  public let accountId: String
  public let fee: Double?
  public let completedAt: String?
  public let rewardsDonation: Double?
  public let roundUpDonation: Double?
  public let oneTimeDonation: Double?
  public let totalDonation: Double?
  
  public init(
    id: String,
    accountId: String,
    fee: Double?,
    completedAt: String?,
    rewardsDonation: Double?,
    roundUpDonation: Double?,
    oneTimeDonation: Double?,
    totalDonation: Double?
  ) {
    self.id = id
    self.accountId = accountId
    self.fee = fee
    self.completedAt = completedAt
    self.rewardsDonation = rewardsDonation
    self.roundUpDonation = roundUpDonation
    self.oneTimeDonation = oneTimeDonation
    self.totalDonation = totalDonation
  }
}
