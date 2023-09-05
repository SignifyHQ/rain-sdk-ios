import Foundation
import NetworkUtilities

public struct WaitListParameter: Parameterable {
  public let request: Request
  
  public struct Request: Codable {
    let waitList: String
  }
}
