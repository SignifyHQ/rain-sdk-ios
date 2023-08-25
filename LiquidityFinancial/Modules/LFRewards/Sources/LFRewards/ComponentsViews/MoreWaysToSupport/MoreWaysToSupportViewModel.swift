import Foundation
import UIKit
import LFLocalizable

@MainActor
class MoreWaysToSupportViewModel: ObservableObject {
  let fundraiser: FundraiserDetailModel
  let social: [Social]
  @Published var navigation: Navigation?
  @Published var showShare = false
  @Published var toastMessage: String?
  
  init(fundraiser: FundraiserDetailModel) {
    self.fundraiser = fundraiser
    social = fundraiser.social
  }
  
  func inviteFriendsTapped() {
    navigation = .referrals
  }
  
  func shareCauseTapped() {
    showShare = true
  }
  
  func photoTapped() {
    guard let url = fundraiser.stickerUrl else { return }
    Task {
      do {
        let (data, _) = try await URLSession.shared.data(from: url)
        if let image = UIImage(data: data) {
          let imageSaver = ImageSaver { error in
            self.toastMessage = error != nil ? LFLocalizable.MoreWaysToSupport.Photo.error : LFLocalizable.MoreWaysToSupport.Photo.success
          }
          imageSaver.writeToPhotoAlbum(image: image)
        }
      } catch {
        toastMessage = LFLocalizable.MoreWaysToSupport.Photo.error
      }
    }
  }
  
  func getTaxableDonationsTapped() {}
}

  // MARK: - Types

extension MoreWaysToSupportViewModel {
  enum Navigation {
    case referrals
  }
  
  struct Social: Hashable {
    let type: SocialType
    let url: URL
  }
  
  enum SocialType: String {
    case email = "ic_email"
    case twitter = "ic_twitter"
    case facebook = "ic_facebook"
    case instagram = "ic_instagram"
  }
}

private extension FundraiserDetailModel {
  var social: [MoreWaysToSupportViewModel.Social] {
    var result: [MoreWaysToSupportViewModel.Social] = []
    if let twitterUrl {
      result.append(.init(type: .twitter, url: twitterUrl))
    }
    if let instagramUrl {
      result.append(.init(type: .instagram, url: instagramUrl))
    }
    if let facebookUrl {
      result.append(.init(type: .facebook, url: facebookUrl))
    }
    return result
  }
}

  // MARK: - ImageSaver

class ImageSaver: NSObject {
  let onResult: (Error?) -> Void
  
  init(onResult: @escaping (Error?) -> Void) {
    self.onResult = onResult
  }
  
  func writeToPhotoAlbum(image: UIImage) {
    UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
  }
  
  @objc
  private func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
    onResult(error)
  }
}
