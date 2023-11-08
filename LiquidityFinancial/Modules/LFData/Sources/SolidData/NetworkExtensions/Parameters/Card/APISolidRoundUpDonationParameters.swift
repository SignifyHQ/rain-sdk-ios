import Foundation
import SolidDomain
import NetworkUtilities

public struct APISolidRoundUpDonationParameters: Parameterable, SolidRoundUpDonationParametersEntity {
  public let roundUpDonation: Bool
  
  public init(roundUpDonation: Bool) {
    self.roundUpDonation = roundUpDonation
  }
}
