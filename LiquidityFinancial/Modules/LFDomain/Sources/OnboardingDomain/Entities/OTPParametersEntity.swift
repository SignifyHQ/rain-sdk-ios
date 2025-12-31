import Foundation

// sourcery: AutoMockable
public protocol OTPParametersEntity {
  var phoneNumber: String? { get }
  var email: String? { get }
  
  init(
    phoneNumber: String?,
    email: String?
  )
}
