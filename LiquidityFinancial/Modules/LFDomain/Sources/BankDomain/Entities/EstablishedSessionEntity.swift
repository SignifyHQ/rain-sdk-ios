import Foundation

public protocol EstablishedSessionEntity {
  var id: String { get }
  var encryptedData: String { get }
}

public protocol EstablishSessionParametersEntity: Codable {
  var encryptedData: String { get }
  init(encryptedData: String)
}
