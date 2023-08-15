import Foundation

public protocol SelectRewardEntity {
  var rewardType: SelectRewardTypeEntity? { get }
}

public protocol SelectRewardTypeEntity {
  static var none: Self { get }
  static var cashBack: Self { get }
  static var reverseCashBack: Self { get }
  static var cryptoBack: Self { get }
  static var reverseCryptoBack: Self { get }
  static var doshCryptoBack: Self { get }
  static var donation: Self { get }
  static var roundUpDonation: Self { get }
  static var referra: Self { get }
  var rawString: String { get }
}
