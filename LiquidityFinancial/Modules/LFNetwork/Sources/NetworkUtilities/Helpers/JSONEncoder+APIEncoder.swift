import Foundation

extension JSONEncoder {
  
  public static let apiEncoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase
    return encoder
  }()
  
  public static let requestEncoder: JSONEncoder = {
    let encoder = JSONEncoder()
    return encoder
  }()
  
}
