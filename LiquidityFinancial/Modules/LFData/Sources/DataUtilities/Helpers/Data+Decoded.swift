import Foundation

public extension Data {
  
  func decoded<T: Decodable>(decoder: JSONDecoder = .apiDecoder) -> T {
    guard let object = try? decoder.decode(T.self, from: self) else { fatalError("Unable to decode \(T.self)") }
    return object
  }
}
