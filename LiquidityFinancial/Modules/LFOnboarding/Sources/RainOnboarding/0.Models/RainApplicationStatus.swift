import Foundation

enum RainApplicationStatus: String {
  case approve
  case inReview
  case rejected
  case needInformation = "rain_user_needs_information"
  case needVerification = "rain_user_needs_verification"
}
