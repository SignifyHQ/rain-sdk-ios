import Foundation
import LFLocalizable

public enum KYCState: Equatable {
  case idle
  case inVerify
  case missingInfo
  case pendingIDV
  case reject
  case inReview(String)
  case common(String)
  case documentInReview
  
  public static func == (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case (idle, idle): return true
    case (inVerify, inVerify): return true
    case (missingInfo, missingInfo): return true
    case (pendingIDV, pendingIDV): return true
    case (reject, reject): return true
    case (documentInReview, documentInReview): return true
    case (common(_), common(_)): return true
    case (inReview(_), inReview(_)): return true
    default: return false
    }
  }
  
  var kycInformation: KYCInformation? {
    switch self {
    case .pendingIDV:
      return KYCInformation(
        title: L10N.Common.KycStatus.IdentityVerification.title,
        message: L10N.Common.KycStatus.IdentityVerification.message,
        primary: L10N.Common.Button.Continue.title
      )
    case .reject:
      return KYCInformation(
        title: L10N.Common.KycStatus.Fail.title,
        message: L10N.Common.KycStatus.Fail.message,
        primary: L10N.Common.Button.Done.title
      )
    case .missingInfo:
      return KYCInformation(
        title: L10N.Common.KycStatus.Fail.title,
        message: L10N.Common.KycStatus.MissingInfo.message,
        primary: L10N.Common.Button.Done.title
      )
    case let .inReview(username):
      return KYCInformation(
        title: L10N.Common.KycStatus.InReview.title,
        message: L10N.Common.KycStatus.InReview.message(username),
        primary: L10N.Common.KycStatus.InReview.primaryTitle,
        secondary: L10N.Common.KycStatus.InReview.secondaryTitle
      )
    case let .common(messagekey):
      return KYCInformation(
        title: L10N.Common.KycStatus.Fail.title,
        message: L10N.Common.KycStatus.Fail.Unclear.message(messagekey),
        primary: L10N.Common.KycStatus.InReview.primaryTitle,
        secondary: L10N.Common.KycStatus.InReview.secondaryTitle
      )
    case .documentInReview:
      return KYCInformation(
        title: L10N.Common.KycStatus.Document.Inreview.title,
        message: L10N.Common.KycStatus.Document.Inreview.message,
        primary: L10N.Common.Button.Ok.title
      )
    default:
      return nil
    }
  }
}
