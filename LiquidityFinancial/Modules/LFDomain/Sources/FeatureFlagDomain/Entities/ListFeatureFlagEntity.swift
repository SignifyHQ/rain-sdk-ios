import Foundation

public protocol ListFeatureFlagEntity {
  var items: [FeatureFlagEntity] { get }
}

public protocol FeatureFlagEntity {
  var id: String { get }
  var key: String { get }
  var productId: String? { get }
  var enabled: Bool { get }
  var description: String? { get }
}
