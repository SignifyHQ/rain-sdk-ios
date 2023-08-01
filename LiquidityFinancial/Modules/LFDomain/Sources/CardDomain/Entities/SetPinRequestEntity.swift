import Foundation

public protocol SetPinRequestEntity: Codable {
  var verifyId: String { get }
  var encryptedData: String { get }
}
