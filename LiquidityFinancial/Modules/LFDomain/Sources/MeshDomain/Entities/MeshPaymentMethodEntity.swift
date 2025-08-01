import Foundation

// sourcery: AutoMockable
public protocol MeshPaymentMethodEntity: Identifiable {
  var methodId: String { get }
  var brokerType: String { get }
  var brokerName: String { get }
  var brokerLogoUrl: String? { get }
  var brokerIconUrl: String? { get }
  var brokerBase64Logo: String? { get }
  var createdAt: String { get }
  var isConnectionExpired: Bool { get }
  var expiresAt: String? { get }
  var lastActiveAt: String? { get }
}
