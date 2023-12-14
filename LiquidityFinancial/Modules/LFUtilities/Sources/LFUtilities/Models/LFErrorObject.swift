import Foundation

public struct LFErrorObject: Codable, LocalizedError {
  public let requestId: String?
  public let message: String
  public let key: String?
  public let sysMessage: String?
  public let code: String?
  public let errorDetail: [String: AnyCodable]?
  
  public init(
    requestId: String? = nil,
    message: String,
    key: String? = nil,
    sysMessage: String? = nil,
    code: String? = nil,
    errorDetail: [String: AnyCodable]? = nil
  ) {
    self.requestId = requestId
    self.message = message
    self.key = key
    self.sysMessage = sysMessage
    self.code = code
    self.errorDetail = errorDetail
  }
  
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
  
  var userFriendlyMessage: String {
    guard let errorObject = self.asErrorObject
    else {
      return self.localizedDescription
    }
    
    return errorObject.message
  }
  
  var inlineError: InlineError? {
    guard let errorObject = self.asErrorObject,
          let inlineErorr = InlineError(rawValue: errorObject.code ?? "")
    else {
      return nil
    }
    
    return inlineErorr
  }
}

public enum InlineError: String {
  case invalidCredentials = "credentials_invalid"
}
