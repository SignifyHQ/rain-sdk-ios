import Foundation

// sourcery: AutoMockable
public protocol RainPersonEntity {
  var liquidityUserId: String { get }
  var rainInternalPersonId: String { get }
  var rainExternalPersonId: String { get }
}
