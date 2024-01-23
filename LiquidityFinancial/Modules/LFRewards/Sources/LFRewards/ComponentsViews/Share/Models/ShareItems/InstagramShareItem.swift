import Combine
import SwiftUI
import LFUtilities
import LFLocalizable

struct InstagramShareItem: ShareItem {
  let data: ShareItemData
  let subject: PassthroughSubject<ShareItemAction, Never>

  var name: String {
    L10N.Common.Share.instagram
  }

  var image: Image {
    ModuleImages.Share.shareInstagram.swiftUIImage
  }

  var isValid: Bool {
    guard let url = url else {
      return false
    }
    return UIApplication.shared.canOpenURL(url) && data.imageUrl != nil
  }

  func share(card: UIImage?) {
    guard let url = url else { return }
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
          "com.instagram.sharedSticker.backgroundImage": NSData(data: shareData)
        ]
        let expirationDate = Date().addingTimeInterval(300)
        UIPasteboard.general.setItems([pasteboardItems], options: [.expirationDate: expirationDate])
        await MainActor.run {
          UIApplication.shared.open(url)
          subject.send(.succeeded)
        }
      } catch {
        log.error("Failure when downloading image: \(error)")
        subject.send(.failed(item: name))
      }
    }
  }

  private var url: URL? {
    guard let appId: String = try? LFConfiguration.value(for: "FACEBOOK_APP_ID") else {
      return nil
    }
    return .init(string: "instagram-stories://share?source_application=\(appId)")
  }
}
