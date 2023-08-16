import UIKit
import SwiftUI
import LFLocalizable

struct TwitterShareItem: ShareItem {
  let data: ShareItemData

  var name: String {
    LFLocalizable.Share.twitter
  }

  var image: Image {
    ModuleImages.Share.shareTwitter.swiftUIImage
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
    .init(string: "twitter://post?message=\(data.messageAndUrl.urlEncoded)")
  }
}
