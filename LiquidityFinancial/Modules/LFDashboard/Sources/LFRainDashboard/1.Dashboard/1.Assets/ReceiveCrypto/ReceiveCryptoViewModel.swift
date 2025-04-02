import Foundation
import GeneralFeature
import AccountDomain
import LFUtilities
import Factory
import CoreImage.CIFilterBuiltins
import UIKit
import LFLocalizable

@MainActor
class ReceiveCryptoViewModel: ObservableObject {
  
  @LazyInjected(\.accountDataManager) var accountDataManager
  @LazyInjected(\.accountRepository) var accountRepository
  
  @Published var isDisplaySheet: Bool = false
  @Published var qrCode = UIImage()
  @Published var isShareSheetViewPresented = false
  @Published var showCloseButton = false
  @Published var toastMessage: String?
  
  let assetTitle: String
  let walletAddress: String
  
  init(assetTitle: String, walletAddress: String) {
    self.assetTitle = assetTitle
    self.walletAddress = walletAddress
  }
}

// MARK: - View Handle
extension ReceiveCryptoViewModel {
  func copyAddress() {
    UIPasteboard.general.string = walletAddress
    toastMessage = L10N.Common.ReceiveCryptoView.Copied.info
  }
  
  func shareTap() {
    isShareSheetViewPresented = true
  }
  
  func updateCode() {
    qrCode = generateQRCode(from: walletAddress)
  }

  func getActivityItems() -> [AnyObject] {
    var objectsToShare = [AnyObject]()

    if let shareImageObj = qrCode.resizedWidth(toWidth: 200) {
      objectsToShare.append(shareImageObj)
    }

    return objectsToShare
  }

  func getApplicationActivities() -> [UIActivity]? {
    nil
  }

  func generateQRCode(from string: String) -> UIImage {
    let context = CIContext()
    let filter = CIFilter.qrCodeGenerator()
    filter.message = Data(string.utf8)

    guard let outputImage = filter.outputImage
    else {
      return UIImage()
    }
    
    let invertedFilter = CIFilter.colorInvert()
    invertedFilter.setValue(outputImage, forKey: kCIInputImageKey)
    
    guard let outputInvertedImage = invertedFilter.outputImage,
          let cgimg = context.createCGImage(outputInvertedImage, from: outputInvertedImage.extent)
    else {
      return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
    
    return UIImage(cgImage: cgimg)
  }
}
