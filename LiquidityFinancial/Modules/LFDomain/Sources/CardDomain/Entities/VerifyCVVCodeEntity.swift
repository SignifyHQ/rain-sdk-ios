import Foundation

public protocol VerifyCVVCodeRequestEntity: Codable {
  var verificationType: String { get }
  var encryptedData: String { get }
}

public protocol VerifyCVVCodeResponseEntity: Codable {
  var id: String { get }
}
