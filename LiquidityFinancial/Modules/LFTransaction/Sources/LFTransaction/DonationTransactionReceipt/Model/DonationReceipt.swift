import Foundation

public struct DonationReceipt {
  public let id: String
  public let accountId: String
  public let fee: Double?
  public let createdAt: String
  public let completedAt: String?
  public let rewardsDonation: Double?
  public let roundUpDonation: Double?
  public let oneTimeDonation: Double?
  public let totalDonation: Double?
  public let fundraiserName: String
  public let charityName: String
  
  public init(
    id: String,
    accountId: String,
    fee: Double?,
    createdAt: String,
    completedAt: String?,
    rewardsDonation: Double?,
    roundUpDonation: Double?,
    oneTimeDonation: Double?,
    totalDonation: Double?,
    fundraiserName: String,
    charityName: String
  ) {
    self.id = id
    self.accountId = accountId
    self.fee = fee
    self.createdAt = createdAt
    self.completedAt = completedAt
    self.rewardsDonation = rewardsDonation
    self.roundUpDonation = roundUpDonation
    self.oneTimeDonation = oneTimeDonation
    self.totalDonation = totalDonation
    self.fundraiserName = fundraiserName
    self.charityName = fundraiserName
  }
}
