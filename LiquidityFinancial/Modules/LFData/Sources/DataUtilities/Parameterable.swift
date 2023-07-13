import Foundation

public protocol Parameterable: Encodable {}

public extension Parameterable {
  
  func encoded(encoder: JSONEncoder = .requestEncoder) -> [String: String] {
    guard let dictionary = try? JSONSerialization.jsonObject(
      with: encoder.encode(self), options: .allowFragments
    ) as? [String: Any] else {
      return [:]
    }
    
    return dictionary.mapValues { "\($0)" }
  }
}
