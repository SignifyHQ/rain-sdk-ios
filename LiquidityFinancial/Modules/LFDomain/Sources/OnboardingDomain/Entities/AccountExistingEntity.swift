import Foundation

public protocol AccountExistingEntity: Decodable {
  var exists: Bool { get set }
}
