import Foundation

// sourcery: AutoMockable
public protocol LoginParametersEntity {
  var phoneNumber: String? { get }
  var email: String? { get }
  
  var code: String { get }
  
  var lastXId: String? { get }
  var verificationEntity: VerificationEntity? { get }
}

public protocol VerificationEntity {
  var type: String { get }
  var secret: String { get }
  
  init(type: String, secret: String)
}
