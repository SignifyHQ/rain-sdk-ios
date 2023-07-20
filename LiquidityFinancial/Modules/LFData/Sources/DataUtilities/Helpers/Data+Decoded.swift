import Foundation

public extension Data {
  
  func decoded<T: Decodable>(decoder: JSONDecoder = .apiDecoder) -> T {
    guard let object = try? decoder.decode(T.self, from: self) else { fatalError("Unable to decode \(T.self)") }
    return object
  }
}

public extension Dictionary {
  
  var jsonString: String {
    let invalidJson = "Not a valid JSON"
    do {
      let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
      return String(bytes: jsonData, encoding: String.Encoding.utf8) ?? invalidJson
    } catch {
      return invalidJson
    }
  }
  
}
