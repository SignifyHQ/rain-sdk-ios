import Foundation

public struct AnyCodable: Codable {
  public let value: Any
  
  public init<T: Codable>(_ value: T) {
    self.value = value
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    if let value = value as? Codable {
      try container.encode(value)
    } else {
      throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: [], debugDescription: "Value is not encodable"))
    }
  }
  
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let stringVal = try? container.decode(String.self) {
      value = stringVal
    } else if let intVal = try? container.decode(Int.self) {
      value = intVal
    } else if let doubleVal = try? container.decode(Double.self) {
      value = doubleVal
    } else if let boolVal = try? container.decode(Bool.self) {
      value = boolVal
    } else if let dictBool = try? container.decode([String: Bool].self) {
      value = dictBool
    } else if let dictStr = try? container.decode([String: String].self) {
      value = dictStr
    } else {
      throw DecodingError.dataCorruptedError(in: container, debugDescription: "Could not decode value")
    }
  }
}
