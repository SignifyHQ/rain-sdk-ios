import Foundation

public struct DebitCardToken: Codable {
  let linkToken: String
  let solidContactId: String
  
  public init(linkToken: String, solidContactId: String) {
    self.linkToken = linkToken
    self.solidContactId = solidContactId
  }
}
