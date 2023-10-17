import Foundation

// sourcery: AutoMockable
public protocol AvailableRewardCurrenciesEntity {
  var availableRewardCurrencies: [String] { get }
  
  init(availableRewardCurrencies: [String])
}
