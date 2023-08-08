import Foundation
import MessageUI
import UIKit

public class EmailHelper: NSObject, MFMailComposeViewControllerDelegate {
  public static let shared = EmailHelper()
  private override init() {}
  
  public func sendEmail(subject: String, body: String, toSubject: String) -> Bool {
    if !MFMailComposeViewController.canSendMail() {
      log.error("No mail account found, Please setup a mail account")
      return false
    }
    
    let picker = MFMailComposeViewController()
    
    picker.setSubject(subject)
    picker.setMessageBody(body, isHTML: true)
    picker.setToRecipients([toSubject])
    picker.mailComposeDelegate = self
    
    EmailHelper.getRootViewController()?.present(picker, animated: true, completion: nil)
    return true
  }
  
  public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
    EmailHelper.getRootViewController()?.dismiss(animated: true, completion: nil)
  }
  
  static func getRootViewController() -> UIViewController? {
    UIApplication.shared.rootViewController
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
