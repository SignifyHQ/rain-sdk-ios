import Foundation
import LFLocalizable
import LFUtilities

struct ShareItemData {
  /// The content of the card that is displayed on the `ShareView` and sometimes even shared to the third party app.
  var card: TransactionCardView.ShareDonationData
  
  /// The message that will be used for apps where the content shared is just text (WhatsApp, Twitter, etc).
  let message: String
  
  /// The url -if any- to include in the shared content. This may already be part of the `message`, but some apps
  /// don't include the message in the shared content (i.e.: Snapchat).
  let attachmentUrl: URL?
  
  /// A boolean indicating whether the user can toggle between sharing the amount donated or not.
  var showAmountToggle: Bool
}

extension ShareItemData {
  var imageUrl: URL? {
    card.imageUrl
  }
  
  var messageAndUrl: String {
    if let url = attachmentUrl?.absoluteString {
      return message + "\n\n" + url
    } else {
      return message
    }
  }
}

extension ShareItemData {
  static func build(from fundraiser: Fundraiser, donation: Double? = nil) -> Self {
    .init(
      card: .init(fundraiser: fundraiser, donation: donation),
      message: LFLocalizable.Share.Card.fundraiser(LFUtility.appName, fundraiser.name),
      attachmentUrl: fundraiser.url ?? .init(string: LFUtility.shareAppUrl),
      showAmountToggle: donation != nil
    )
  }
  
  static func build(from sticker: Sticker) -> Self {
    .init(
      card: .init(
        title: sticker.name,
        message: LFLocalizable.TransactionCard.ShareDonationGeneric.message(sticker.name, LFUtility.appName, sticker.charityName ?? sticker.name),
        backgroundColor: sticker.backgroundColor?.asHexColor,
        imageUrl: sticker.url
      ),
      message: LFLocalizable.Share.Card.fundraiser(LFUtility.appName, sticker.name),
      attachmentUrl: .init(string: LFUtility.shareAppUrl),
      showAmountToggle: false
    )
  }
}
