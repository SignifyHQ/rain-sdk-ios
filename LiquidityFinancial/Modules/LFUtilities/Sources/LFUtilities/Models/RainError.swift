import Foundation

public struct RainError: Codable, LocalizedError {
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
    let errorTitle = message.isEmpty ? (sysMessage ?? "An error occurred") : message
    let codeSuffix = code.map { ", code: \($0)" } ?? ""
    
    return "\(errorTitle)\(codeSuffix)"
  }
  
  public var description: String {
    let detail = key.map { "key: \($0), " } ?? ""
    return "RainError: \(errorDescription ?? "Unknown Error") (\(detail)requestId: \(requestId ?? "n/a"))"
  }
}

// MARK: - Domain Specific Errors

/**
 Defines specific, domain-level errors based on known error codes.
 Using a specific protocol (`SpecificError`) is a modern pattern
 to improve clarity over simple String raw values.
 */
public enum DomainError: String {
  case authPasswordInvalid = "invalid_auth_password"
  case totpInvalid = "invalid_totp"
  case otpInvalid = "credentials_invalid"
  case verificationInvalid = "verification_invalid"
}

// MARK: - Error Extension

public extension Error {
  var rainError: RainError? {
    self as? RainError
  }
  
  var displayableErrorMessage: String {
    rainError?.message ?? self.localizedDescription
  }
  
  var domainError: DomainError? {
    rainError?.code.flatMap { codeString in
      DomainError(rawValue: codeString)
    }
  }
}
