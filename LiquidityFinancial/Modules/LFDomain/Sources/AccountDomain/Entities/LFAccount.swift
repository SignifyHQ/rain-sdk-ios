import Foundation

// sourcery: AutoMockable
public protocol LFAccount {
  var id: String { get }
  var externalAccountId: String? { get }
  var currency: String { get }
  var availableBalance: Double { get }
  var availableUsdBalance: Double { get }
  
  init(id: String, externalAccountId: String?, currency: String, availableBalance: Double, availableUsdBalance: Double)
}
