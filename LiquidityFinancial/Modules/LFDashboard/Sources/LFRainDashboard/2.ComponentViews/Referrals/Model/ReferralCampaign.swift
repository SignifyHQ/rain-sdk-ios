import Foundation
import LFUtilities
import LFLocalizable

struct ReferralCampaign {
  let name: String
  let inviterBonusAmount: String
  let inviteeBonusAmount: String
  let currency: String
  let period: Int
  let timeUnit: TimeUnit
}

extension ReferralCampaign {
  enum TimeUnit: String, Codable {
    case day
    case week
  }
}

// Helper
extension ReferralCampaign {
  var periodDisplay: String {
    switch timeUnit {
    case .day:
      return L10N.Common.Referral.Campaign.day(period)
    case .week:
      return L10N.Common.Referral.Campaign.day(period)
    }
  }
  
  var inviterBonusDisplay: String {
    if currency == "USD" {
      return inviterBonusAmount.formattedUSDAmount()
    } else {
      return "\(inviterBonusAmount.formattedAmount()) \(currency))"
    }
  }
}
