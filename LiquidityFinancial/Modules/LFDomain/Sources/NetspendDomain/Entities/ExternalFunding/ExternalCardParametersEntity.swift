import Foundation

// sourcery: AutoMockable
public protocol ExternalCardExpirationEntity: Codable {
  var month: String { get }
  var year: String { get }
}

// sourcery: AutoMockable
public protocol ExternalCardParametersEntity: Codable {
  var encryptedData: String { get }
  var expirationEntity: ExternalCardExpirationEntity { get }
  var nameOnCard: String { get }
  var nickname: String { get }
  var postalCode: String { get }
}
