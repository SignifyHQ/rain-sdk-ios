import Foundation
import LFUtilities
import ZendeskSDK

public class EmailService: CustomerSupportServiceProtocol {
  public init() {}
  
  public var isLoginIdentifiedSuccess: Bool {
    true
  }
  
  var toEmail: String {
    switch LFUtilities.target {
    case .CauseCard:
      return "help@getcausecard.com"
    case .PrideCard:
      return "help@paywithpride.com"
    case .DogeCard:
      return "help@dogecard.com"
    case .PawsCard:
      return ""
    case .Avalanche:
      return "support@avalanchecard.com"
    case .Cardano:
      return ""
    case .none:
      return ""
    }
  }
  
  var currentDate: String {
    let currentDate = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMM dd"
    let formattedDate = dateFormatter.string(from: currentDate)
    return formattedDate
  }
  
  var subject: String {
    switch LFUtilities.target {
    case .CauseCard:
      return "CauseCard Support Request - \(currentDate)"
    case .PrideCard:
      return "PrideCard Support Request - \(currentDate)"
    case .DogeCard:
      return "DogeCard Support Request - \(currentDate)"
    case .PawsCard:
      return ""
    case .Avalanche:
      return "Avalanche Card Support Request - \(currentDate)"
    case .Cardano:
      return ""
    case .none:
      return ""
    }
  }
  
  public func openSupportScreen() {
    DispatchQueue.main.async { [weak self] in
      guard let self
      else {
        return
      }
      
      if let viewController = Zendesk.instance?.messaging?.messagingViewController(),
         let topViewController = LFUtilities.visibleViewController {
        topViewController.present(viewController, animated: true)
      } else {
        log.info("Failed to present Zendesk messaging view controller, falling back to email...")
        
        EmailHelper
          .shared
          .send(
            subject: subject,
            body: "",
            toRecipents: [toEmail]
          )
      }
    }
  }
}
