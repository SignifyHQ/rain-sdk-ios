import Foundation

public struct DonationModel: Identifiable {
  public let id: String
  public let title: String
  public let message: String
  public let fundraiserId: String
  public let amount: Double
  public let totalDonation: Double
  public let stickerURL: String?
  public let backgroundColor: String
  public let status: DonationStatus
  public let createdAt: String
  
  static var `default` = DonationModel(
    id: .empty,
    title: .empty,
    message: .empty,
    fundraiserId: .empty,
    amount: 0,
    totalDonation: 0,
    stickerURL: nil,
    backgroundColor: .empty,
    status: .unknown,
    createdAt: .empty
  )
  
  func transactionDateInLocalZone(includeYear: Bool = false) -> String {
    createdAt.serverToTransactionDisplay(includeYear: includeYear)
  }
}
