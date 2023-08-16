import Foundation

public struct Response {
  
  public let httpResponse: HTTPURLResponse?
  public let data: Data?
  
  public init(httpResponse: HTTPURLResponse?, data: Data?) {
    self.httpResponse = httpResponse
    self.data = data
  }
}
