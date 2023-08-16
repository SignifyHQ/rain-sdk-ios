import Foundation
import MessageUI
import LFUtilities
import SwiftUI
import LFLocalizable

struct EmailShareItem: ShareItem {
  let data: ShareItemData

  private let mailComposeDelegate = MailDelegate()

  var name: String {
    LFLocalizable.Share.email
  }

  var image: Image {
    ModuleImages.Share.shareEmail.swiftUIImage
  }

  var isValid: Bool {
    MFMailComposeViewController.canSendMail()
  }

  func share(card: UIImage?) {
    guard let viewController = LFUtility.visibleViewController else {
      return log.error("Unable to find visible view controller for EmailShareItem")
    }

    let composeVC = MFMailComposeViewController()
    composeVC.mailComposeDelegate = mailComposeDelegate
    composeVC.setMessageBody(data.message, isHTML: false)

    viewController.present(composeVC, animated: true)
  }
}

// MARK: - MFMailComposeViewControllerDelegate

extension EmailShareItem {
  private class MailDelegate: NSObject, MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
      controller.dismiss(animated: true)
    }
  }
}
