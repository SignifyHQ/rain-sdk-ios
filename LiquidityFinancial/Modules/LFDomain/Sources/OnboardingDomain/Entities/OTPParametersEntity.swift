import Foundation

// sourcery: AutoMockable
public protocol OTPParametersEntity {
  var phoneNumber: String { get }
  
  init(phoneNumber: String)
}
