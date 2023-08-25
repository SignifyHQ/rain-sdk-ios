import Foundation
import SwiftUI
import LFLocalizable
import LFUtilities

public struct ShareItemData {
    /// The content of the card that is displayed on the `ShareView` and sometimes even shared to the third party app.
  var card: ShareDonationData
  
    /// The message that will be used for apps where the content shared is just text (WhatsApp, Twitter, etc).
  let message: String
  
    /// The url -if any- to include in the shared content. This may already be part of the `message`, but some apps
    /// don't include the message in the shared content (i.e.: Snapchat).
  let attachmentUrl: URL?
  
    /// A boolean indicating whether the user can toggle between sharing the amount donated or not.
  var showAmountToggle: Bool
  
  struct ShareDonationData {
    let title: String
    let messageGeneric: String
    let messageDonation: String
    let backgroundColor: Color?
    let imageUrl: URL?
    var includeDonation: Bool
    
    init(title: String, message: String, backgroundColor: Color?, imageUrl: URL? = nil) {
      self.title = title
      messageGeneric = message
      messageDonation = message
      self.backgroundColor = backgroundColor
      self.imageUrl = imageUrl
      includeDonation = false
    }
    
    init(fundraiserDetail: FundraiserDetailModel, donation: Double?) {
      title = fundraiserDetail.name
      backgroundColor = fundraiserDetail.fundraiser?.backgroundColor?.asHexColor ?? ModuleColors.separator.swiftUIColor
      imageUrl = fundraiserDetail.stickerUrl
      
      messageGeneric = LFLocalizable.Fundraise.ShareDonation.generic(fundraiserDetail.charityName, LFUtility.appName, fundraiserDetail.name)
      if let donation {
        let amount = donation.formattedAmount(prefix: "$", minFractionDigits: 2, absoluteValue: true)
        
        messageDonation = LFLocalizable.Fundraise.ShareDonation.amount(amount, fundraiserDetail.charityName, LFUtility.appName, fundraiserDetail.name)
      } else {
        messageDonation = messageGeneric
      }
      includeDonation = false
    }
  }
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
  public static func build(from fundraiserDetail: FundraiserDetailModel, donation: Double? = nil) -> Self {
    .init(
      card: .init(fundraiserDetail: fundraiserDetail, donation: donation),
      message: String(format: LFLocalizable.Cause.Share.Card.fundraiser(fundraiserDetail.name)),
      attachmentUrl: fundraiserDetail.charityUrl ?? .init(string: LFUtility.shareAppUrl),
      showAmountToggle: donation != nil
    )
  }
  
  public static func build(sticker: StickerModel) -> Self {
    .init(
      card: .init(
        title: sticker.name,
        message: LFLocalizable.Fundraise.ShareDonation.generic(sticker.name, LFUtility.appName, sticker.charityName ?? sticker.name),
        backgroundColor: sticker.backgroundColor?.asHexColor,
        imageUrl: sticker.url
      ),
      message: LFLocalizable.Cause.Share.Card.fundraiser(sticker.name),
      attachmentUrl: .init(string: LFUtility.shareAppUrl),
      showAmountToggle: false
    )
  }
}
