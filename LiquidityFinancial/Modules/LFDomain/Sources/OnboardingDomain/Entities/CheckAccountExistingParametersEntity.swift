import Foundation

// sourcery: AutoMockable
public protocol CheckAccountExistingParametersEntity {
  var productId: String { get }
  
  var phone: String? { get }
  var email: String? { get }
}
