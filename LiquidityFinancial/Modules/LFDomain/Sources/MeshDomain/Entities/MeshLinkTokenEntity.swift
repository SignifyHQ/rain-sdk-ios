import Foundation

// sourcery: AutoMockable
public protocol MeshLinkTokenEntity {
  var linkToken: String { get }
  var brokerType: String? { get }
  var brokerName: String? { get }
  var brokerLogoUrl: String? { get }
  var brokerIconUrl: String? { get }
  var accountId: String? { get }
  var accountName: String? { get }
  var accessToken: String? { get }
}
