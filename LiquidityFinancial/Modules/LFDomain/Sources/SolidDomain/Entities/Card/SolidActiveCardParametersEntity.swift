import Foundation

// sourcery: AutoMockable
public protocol SolidActiveCardParametersEntity {
  var expiryMonth: String { get }
  var expiryYear: String { get }
  var last4: String { get }
}
