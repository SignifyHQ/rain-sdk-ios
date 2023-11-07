import Foundation

// sourcery: AutoMockable
public protocol ZerohashAccountEntity {
  var id: String { get }
  var externalAccountId: String? { get }
  var currency: String { get }
  var availableBalance: Double { get }
  var availableUsdBalance: Double { get }
}
