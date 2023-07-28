import Foundation

public struct LFErrorObject: Codable, LocalizedError {
  public let requestId: String?
  public let message: String
  public let key: String?
  public let sysMessage: String?
  public let code: String?
  public let errorDetail: [String: AnyCodable]?
  
  public var errorDescription: String? {
    if message.isEmpty {
      return "\(sysMessage ?? ""), code: \(code ?? "")"
    }
    return "\(message) , code: \(code ?? "")"
  }
}

public extension Error {
  var asErrorObject: LFErrorObject? {
    self as? LFErrorObject
  }
}
