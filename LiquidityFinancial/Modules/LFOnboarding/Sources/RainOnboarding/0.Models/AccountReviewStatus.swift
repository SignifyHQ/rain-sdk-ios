import Foundation
import LFLocalizable

public enum AccountReviewStatus: Equatable {
  case idle
  case missingInformation
  case identityVerification
  case reject
  case inReview(String)
  case unclear(String)
  
  public static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case (.idle, .idle),
      (.missingInformation, .missingInformation),
      (.identityVerification, .identityVerification),
      (.reject, .reject),
      (.unclear(_), .unclear(_)),
      (.inReview(_), .inReview(_)):
      return true
    default:
      return false
    }
  }
  
  var accountReviewInformation: AccountReviewInformation? {
    switch self {
    case .reject:
      return AccountReviewInformation(
        title: L10N.Common.ApplicationReviewStatus.Fail.title,
        message: L10N.Common.ApplicationReviewStatus.Fail.message,
        secondary: L10N.Common.ApplicationReviewStatus.Fail.secondaryTitle
      )
    case let .inReview(username):
      return AccountReviewInformation(
        title: L10N.Common.ApplicationReviewStatus.InReview.title,
        message: L10N.Common.ApplicationReviewStatus.InReview.message,
        primary: L10N.Common.ApplicationReviewStatus.InReview.primaryTitle,
        secondary: L10N.Common.ApplicationReviewStatus.InReview.secondaryTitle
      )
    case .missingInformation:
      return AccountReviewInformation(
        title: L10N.Common.ApplicationReviewStatus.Fail.title,
        message: L10N.Common.ApplicationReviewStatus.MissingInformation.message,
        primary: L10N.Common.Button.Continue.title
      )
    case .identityVerification:
      return AccountReviewInformation(
        title: L10N.Common.ApplicationReviewStatus.IdentityVerification.title,
        message: L10N.Common.ApplicationReviewStatus.IdentityVerification.message,
        primary: L10N.Common.Button.Continue.title
      )
    case let .unclear(messagekey):
      return AccountReviewInformation(
        title: L10N.Common.ApplicationReviewStatus.Fail.title,
        message: L10N.Common.ApplicationReviewStatus.Fail.Unclear.message(messagekey),
        primary: L10N.Common.ApplicationReviewStatus.InReview.primaryTitle,
        secondary: L10N.Common.ApplicationReviewStatus.InReview.secondaryTitle
      )
    default:
      return nil
    }
  }
}
