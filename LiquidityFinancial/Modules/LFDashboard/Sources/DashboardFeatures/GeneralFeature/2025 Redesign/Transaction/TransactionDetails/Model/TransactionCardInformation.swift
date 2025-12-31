import SwiftUI
import LFStyleGuide
import LFLocalizable
import LFUtilities

public struct TransactionCardInformation {
  let cardType: TransactionCardType
  let amount: String
  let rewardAmount: String
  let message: String
  let activityItem: String
  let stickerUrl: String?
  let color: String?
  
  public init(
    cardType: TransactionCardType,
    amount: String,
    rewardAmount: String,
    message: String,
    activityItem: String,
    stickerUrl: String?,
    color: String?
  ) {
    self.cardType = cardType
    self.amount = amount
    self.rewardAmount = rewardAmount
    self.message = message
    self.activityItem = activityItem
    self.color = color
    self.stickerUrl = stickerUrl
  }
}

public extension TransactionCardInformation {
  var title: String {
    switch cardType {
    case .cashback:
      return L10N.Common.TransactionCard.Cashback.title
    case .donation:
      return L10N.Common.TransactionCard.Donation.title
    case .crypto:
      return L10N.Common.TransactionCard.Crypto.title(LFUtilities.stablecoinSymbol)
    default:
      return .empty
    }
  }
  
  var backgroundColor: Color {
    switch cardType {
    case .donation:
      return color?.asHexColor ?? Colors.separator.swiftUIColor.opacity(0.5)
    case .crypto:
      return Colors.primary.swiftUIColor
    case .cashback:
      return color?.asHexColor ?? Colors.secondaryBackground.swiftUIColor
    default:
      return Colors.separator.swiftUIColor.opacity(0.5)
    }
  }
}

public enum TransactionCardType {
  case crypto
  case cashback
  case donation
  case unknow
}
