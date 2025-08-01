import Foundation

// sourcery: AutoMockable
public protocol MeshConnectionEntity {
  var brokerType: String { get }
  var brokerName: String { get }
  var brokerLogoUrl: String? { get }
  var brokerIconUrl: String? { get }
  var brokerBase64Logo: String? { get }
  var accountId: String { get }
  var accountName: String { get }
  var accessToken: String { get }
  var refreshToken: String? { get }
  var expiresInSeconds: Int? { get }
  var meshAccountId: String? { get }
  var frontAccountId: String? { get }
  var fund: Double? { get }
  var cash: Double? { get }
}
