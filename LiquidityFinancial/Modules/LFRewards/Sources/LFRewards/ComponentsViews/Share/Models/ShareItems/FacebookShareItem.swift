import Combine
import SwiftUI
import LFUtilities
import LFLocalizable

struct FacebookShareItem: ShareItem {
  let data: ShareItemData
  let subject: PassthroughSubject<ShareItemAction, Never>

  var name: String {
    L10N.Common.Share.facebook
  }

  var image: Image {
    ModuleImages.Share.shareFacebook.swiftUIImage
  }

  var isValid: Bool {
    guard let url = url else {
      return false
    }
    return UIApplication.shared.canOpenURL(url) && data.imageUrl != nil
  }

  func share(card: UIImage?) {
    guard
      let appId: String = try? LFConfiguration.value(for: "FACEBOOK_APP_ID"),
      let url = url
    else {
      return
    }
    subject.send(.startLoading(item: name))
    Task.detached {
      do {
        let shareData: Data
        if let cardData = card?.jpegData(compressionQuality: 1.0) {
          shareData = cardData
        } else if let stickerUrl = data.imageUrl {
          shareData = try await URLSession.shared.data(from: stickerUrl).0
        } else {
          shareData = Data()
        }
        let pasteboardItems = [
          "com.facebook.sharedSticker.backgroundImage": NSData(data: shareData),
          "com.facebook.sharedSticker.appID": appId
        ] as [String: Any]
        let expirationDate = Date().addingTimeInterval(300)
        UIPasteboard.general.setItems([pasteboardItems], options: [.expirationDate: expirationDate])
        await MainActor.run {
          UIApplication.shared.open(url)
          subject.send(.succeeded)
        }
      } catch {
        log.error("Failure when downloading image:\(error)")
        subject.send(.failed(item: name))
      }
    }
  }

  private var url: URL? {
    .init(string: "facebook-stories://share")
  }
}
