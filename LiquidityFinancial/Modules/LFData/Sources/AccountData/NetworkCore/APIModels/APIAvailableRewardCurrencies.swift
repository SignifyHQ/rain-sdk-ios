import Foundation
import AccountDomain

public struct APIAvailableRewardCurrencies: Decodable, AvailableRewardCurrenciesEntity {
  public let availableRewardCurrencies: [String]
  
  public init(availableRewardCurrencies: [String]) {
    self.availableRewardCurrencies = availableRewardCurrencies
  }
}
