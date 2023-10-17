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
        title: LFLocalizable.KycStatus.IdentityVerification.title,
        message: LFLocalizable.KycStatus.IdentityVerification.message,
        primary: LFLocalizable.Button.Continue.title
      )
    case .reject:
      return KYCInformation(
        title: LFLocalizable.KycStatus.Fail.title,
        message: LFLocalizable.KycStatus.Fail.message,
        primary: LFLocalizable.Button.Done.title
      )
    case .missingInfo:
      return KYCInformation(
        title: LFLocalizable.KycStatus.Fail.title,
        message: LFLocalizable.KycStatus.MissingInfo.message,
        primary: LFLocalizable.Button.Done.title
      )
    case let .inReview(username):
      return KYCInformation(
        title: LFLocalizable.KycStatus.InReview.title,
        message: LFLocalizable.KycStatus.InReview.message(username),
        primary: LFLocalizable.KycStatus.InReview.primaryTitle,
        secondary: LFLocalizable.KycStatus.InReview.secondaryTitle
      )
    case let .common(messagekey):
      return KYCInformation(
        title: LFLocalizable.KycStatus.Fail.title,
        message: LFLocalizable.KycStatus.Fail.Unclear.message(messagekey),
        primary: LFLocalizable.KycStatus.InReview.primaryTitle,
        secondary: LFLocalizable.KycStatus.InReview.secondaryTitle
      )
    case .documentInReview:
      return KYCInformation(
        title: LFLocalizable.KycStatus.Document.Inreview.title,
        message: LFLocalizable.KycStatus.Document.Inreview.message,
        primary: LFLocalizable.Button.Ok.title
      )
    default:
      return nil
    }
  }
}
