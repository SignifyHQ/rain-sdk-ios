import Foundation

public protocol Parameterable: Encodable {}

public extension Parameterable {
  
  func encoded(encoder: JSONEncoder = .requestEncoder) -> [String: Any] {
    guard let dictionary = try? JSONSerialization.jsonObject(
      with: encoder.encode(self), options: []) as? [String: Any] else {
      return [:]
    }
    return dictionary
  }
}
