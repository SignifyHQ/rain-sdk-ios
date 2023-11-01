import Foundation

// sourcery: AutoMockable
public protocol SolidContactEntity {
  var name: String? { get }
  var last4: String { get }
  var type: String { get }
  var solidContactId: String { get }
}
