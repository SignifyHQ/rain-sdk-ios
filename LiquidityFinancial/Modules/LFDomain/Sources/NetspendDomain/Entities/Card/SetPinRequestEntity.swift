import Foundation

// sourcery: AutoMockable
public protocol SetPinRequestEntity: Codable {
  var verifyId: String { get }
  var encryptedData: String { get }
}
