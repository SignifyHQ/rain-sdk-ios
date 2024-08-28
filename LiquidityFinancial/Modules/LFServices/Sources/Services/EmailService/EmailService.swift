import Foundation
import LFUtilities

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
      return ""
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
      return ""
    case .Cardano:
      return ""
    case .none:
      return ""
    }
  }
  
  public func openSupportScreen() {
    EmailHelper.shared.send(subject: subject, body: "", toRecipents: [toEmail])
  }
  
}
