import UIKit
import SwiftUI
import LFLocalizable

struct WhatsappShareItem: ShareItem {
  let data: ShareItemData

  var name: String {
    L10N.Common.Share.whatsapp
  }

  var image: Image {
    ModuleImages.Share.shareWhatsapp.swiftUIImage
  }

  var isValid: Bool {
    guard let url = url else {
      return false
    }
    return UIApplication.shared.canOpenURL(url)
  }

  func share(card: UIImage?) {
    if let url {
      UIApplication.shared.open(url)
    }
  }

  private var url: URL? {
    .init(string: "whatsapp://send?text=\(data.messageAndUrl.urlEncoded)")
  }
}
