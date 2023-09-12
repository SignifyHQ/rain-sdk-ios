import Foundation

public protocol UserDonationSummaryEntity {
  associatedtype APIDonationSticker: DonationStickerEntity
  var donationAmount: Double? { get }
  var donationCount: Int? { get }
  var stickers: [APIDonationSticker] { get }
}

public protocol DonationStickerEntity {
  var fundraiserId: String? { get }
  var stickerUrl: String? { get }
  var donationCount: Int? { get }
}
