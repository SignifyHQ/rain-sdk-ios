import Foundation
import MessageUI
import UIKit

public class EmailHelper: NSObject {
  public static let shared = EmailHelper()
  private override init() {}
}

extension EmailHelper {
  
  /// Remeber to add the below code to Info.plist
  ///    <key>LSApplicationQueriesSchemes</key>
  ///    <array>
  ///       <string>googlegmail</string>
  ///       <string>ms-outlook</string>
  ///    </array>
  public func send(subject: String, body: String, toRecipents: [String]) {
    guard let viewController = EmailHelper.getRootViewController() else {
      return
    }
    
    if !MFMailComposeViewController.canSendMail() {
      let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
      let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
      let mails = toRecipents.joined(separator: ",")
      
      let alert = UIAlertController(title: "Cannot open Mail!", message: "", preferredStyle: .actionSheet)
      
      var haveExternalMailbox = false
      
      if let defaultUrl = URL(string: "mailto:\(mails)?subject=\(subjectEncoded)&body=\(bodyEncoded)"),
         UIApplication.shared.canOpenURL(defaultUrl) {
        haveExternalMailbox = true
        alert.addAction(UIAlertAction(title: "Mail", style: .default, handler: { _ in
          UIApplication.shared.open(defaultUrl)
        }))
      }
      
      if let gmailUrl = URL(string: "googlegmail://co?to=\(mails)&subject=\(subjectEncoded)&body=\(bodyEncoded)"),
         UIApplication.shared.canOpenURL(gmailUrl) {
        haveExternalMailbox = true
        alert.addAction(UIAlertAction(title: "Gmail", style: .default, handler: { _ in
          UIApplication.shared.open(gmailUrl)
        }))
      }
      
      if let outlooklUrl = URL(string: "ms-outlook://co?to=\(mails)&subject=\(subjectEncoded)&body=\(bodyEncoded)"),
         UIApplication.shared.canOpenURL(outlooklUrl) {
        haveExternalMailbox = true
        alert.addAction(UIAlertAction(title: "Outlook", style: .default, handler: { _ in
          UIApplication.shared.open(outlooklUrl)
        }))
      }
      
      if haveExternalMailbox {
        alert.message = "Would you like to open an external mailbox?"
      } else {
        alert.message = "Please add your mail to Settings before using the mail service."
        
        log.info("No mail account found, Please setup a mail account")
        
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString),
           UIApplication.shared.canOpenURL(settingsUrl) {
          alert.addAction(UIAlertAction(title: "Open Settings App", style: .default, handler: { _ in
            UIApplication.shared.open(settingsUrl)
          }))
        }
      }
      
      alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
      viewController.present(alert, animated: true, completion: nil)
      return
    }
    
    let mailCompose = MFMailComposeViewController()
    mailCompose.setSubject(subject)
    mailCompose.setMessageBody(body, isHTML: false)
    mailCompose.setToRecipients(toRecipents)
    mailCompose.mailComposeDelegate = self
    
    viewController.present(mailCompose, animated: true, completion: nil)
  }
  
  static func getRootViewController() -> UIViewController? {
    UIApplication.shared.rootViewController
  }
}

// MARK: - MFMailComposeViewControllerDelegate
extension EmailHelper: MFMailComposeViewControllerDelegate {
  
  public func mailComposeController(_ controller: MFMailComposeViewController,
                                    didFinishWith result: MFMailComposeResult,
                                    error: Error?) {
    switch result {
    case MFMailComposeResult.cancelled:
      log.debug("Mail cancelled")
    case MFMailComposeResult.saved:
      log.debug("Mail saved")
    case MFMailComposeResult.sent:
      log.debug("Mail sent")
    case MFMailComposeResult.failed:
      log.error("Mail sent failure: \(String(describing: error?.localizedDescription))")
    default:
      break
    }
    controller.dismiss(animated: true, completion: nil)
  }
}

extension UIApplication {
  var currentKeyWindow: UIWindow? {
    UIApplication.shared.connectedScenes
      .filter { $0.activationState == .foregroundActive }
      .map { $0 as? UIWindowScene }
      .compactMap { $0 }
      .first?.windows
      .first(where: { $0.isKeyWindow })
  }
  
  var rootViewController: UIViewController? {
    currentKeyWindow?.rootViewController
  }
}
