import Foundation

public protocol AvailableRewardCurrenciesEntity {
  var availableRewardCurrencies: [String] { get }
  
  init(availableRewardCurrencies: [String])
}
