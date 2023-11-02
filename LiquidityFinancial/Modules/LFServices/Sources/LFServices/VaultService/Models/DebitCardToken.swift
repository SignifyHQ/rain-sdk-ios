import Foundation

public struct DebitCardToken: Codable {
  public let linkToken: String
  public let solidContactId: String
  
  public init(linkToken: String, solidContactId: String) {
    self.linkToken = linkToken
    self.solidContactId = solidContactId
  }
}
