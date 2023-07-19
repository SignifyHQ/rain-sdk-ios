import Foundation
import LFLocalizable

enum KYCState {
  case idle
  case inVerify
  case pendingIDV
  case declined
  case inReview(String)
  
  var kycInformation: KYCInformation? {
    switch self {
      case .pendingIDV:
        return KYCInformation(
          title: LFLocalizable.KycStatus.IdentityVerification.title,
          message: LFLocalizable.KycStatus.IdentityVerification.message,
          primary: LFLocalizable.Button.Continue.title
        )
      case .declined:
        return KYCInformation(
          title: LFLocalizable.KycStatus.Fail.title,
          message: LFLocalizable.KycStatus.Fail.message,
          primary: LFLocalizable.Button.Continue.title
        )
      case let .inReview(username):
        return KYCInformation(
          title: LFLocalizable.KycStatus.InReview.title,
          message: LFLocalizable.KycStatus.InReview.message(username),
          primary: LFLocalizable.KycStatus.InReview.primaryTitle,
          secondary: LFLocalizable.KycStatus.InReview.secondaryTitle
        )
      default:
        return nil
    }
  }
}
