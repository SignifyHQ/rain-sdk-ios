import Foundation

public protocol ExternalCardExpirationEntity: Codable {
  var month: String { get }
  var year: String { get }
}

public protocol ExternalCardParametersEntity: Codable {
  var encryptedData: String { get }
  var expiration: ExternalCardExpirationEntity { get }
  var nameOnCard: String { get }
  var nickname: String { get }
  var postalCode: String { get }
}
