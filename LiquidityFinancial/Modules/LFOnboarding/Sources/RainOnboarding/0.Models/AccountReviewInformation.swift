import Foundation

struct AccountReviewInformation {
  let title: String
  let message: String
  let primary: String?
  let secondary: String?
  
  init(title: String, message: String, primary: String? = nil, secondary: String? = nil) {
    self.title = title
    self.message = message
    self.primary = primary
    self.secondary = secondary
  }
}
