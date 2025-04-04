import Foundation

public protocol UnsupportedStateEntity {
  var id: String { get }
  var countryCode: String { get }
  var stateCode: String { get }
  var stateName: String { get }
  var status: String { get }
  var description: String { get }
  var isRelease: Bool { get }
  var releasedAt: String? { get }
  var createdAt: String { get }
  var updatedAt: String { get }
}
