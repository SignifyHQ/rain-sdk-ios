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
      "help@getcausecard.com"
    case .PrideCard:
      "help@paywithpride.com"
    case .DogeCard:
      ""
    case .PawsCard:
      ""
    case .Avalanche:
      ""
    case .Cardano:
      ""
    case .DogeCardNobank:
      ""
    case .none:
      ""
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
      "CauseCard Support Request - \(currentDate)"
    case .PrideCard:
      "PrideCard Support Request - \(currentDate)"
    case .DogeCard:
      ""
    case .PawsCard:
      ""
    case .Avalanche:
      ""
    case .Cardano:
      ""
    case .DogeCardNobank:
      ""
    case .none:
      ""
    }
  }
  
  public func openSupportScreen() {
    EmailHelper.shared.send(subject: subject, body: "", toRecipents: [toEmail])
  }
  
}
