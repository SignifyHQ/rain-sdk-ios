import Foundation

public extension KeyedDecodingContainer {
  func decodeUrl(forKey key: KeyedDecodingContainer<K>.Key) throws -> URL? {
    if let urlStr = try decodeIfPresent(String.self, forKey: key) {
      return .init(string: urlStr)
    } else {
      return nil
    }
  }
}
