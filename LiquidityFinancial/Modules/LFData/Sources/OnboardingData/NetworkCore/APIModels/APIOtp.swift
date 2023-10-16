import Foundation

public struct APIOtp: Codable {
  public let requiredAuth: [String]
  
  public init(requiredAuth: [String]) {
    self.requiredAuth = requiredAuth
  }
}
