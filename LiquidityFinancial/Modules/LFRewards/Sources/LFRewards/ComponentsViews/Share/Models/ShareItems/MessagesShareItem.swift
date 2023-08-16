import MessageUI
import SwiftUI
import LFUtilities
import LFLocalizable

struct MessagesShareItem: ShareItem {
  let data: ShareItemData

  private let messageComposeDelegate = MessageDelegate()

  var name: String {
    LFLocalizable.Share.messages
  }

  var image: Image {
    ModuleImages.Share.shareMessages.swiftUIImage
  }

  var isValid: Bool {
    MFMessageComposeViewController.canSendText()
  }

  func share(card: UIImage?) {
    guard let viewController = LFUtility.visibleViewController else {
      return log.error("Unable to find visible view controller for MessagesShareItem")
    }
    let composeVC = MFMessageComposeViewController()
    composeVC.messageComposeDelegate = messageComposeDelegate
    composeVC.body = data.messageAndUrl
    if let cardData = card?.jpegData(compressionQuality: 1.0) {
      composeVC.addAttachmentData(cardData, typeIdentifier: "image/jpeg", filename: "card.jpeg")
    }

    viewController.present(composeVC, animated: true)
  }
}

// MARK: - MFMessageComposeViewControllerDelegate

extension MessagesShareItem {
  private class MessageDelegate: NSObject, MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
      controller.dismiss(animated: true)
    }
  }
}
