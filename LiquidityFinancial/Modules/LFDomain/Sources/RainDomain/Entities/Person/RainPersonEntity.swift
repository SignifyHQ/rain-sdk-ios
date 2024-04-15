import Foundation

// sourcery: AutoMockable
public protocol RainPersonEntity {
  var liquidityUserId: String { get }
  var internalPersonId: String { get }
  var externalPersonId: String { get }
}
