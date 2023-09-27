import Foundation

public protocol DecodableDefaultSource {
  associatedtype Value: Decodable
  static var defaultValue: Value { get }
}

public enum DecodableDefault {}

extension DecodableDefault {
  @propertyWrapper
  public struct Wrapper<Source: DecodableDefaultSource> {
    public typealias Value = Source.Value
    public var wrappedValue = Source.defaultValue
    public init(wrappedValue: Value = Source.defaultValue) {
      self.wrappedValue = wrappedValue
    }
  }
}

extension DecodableDefault.Wrapper: Decodable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    wrappedValue = try container.decode(Value.self)
  }
}

extension KeyedDecodingContainer {
   public func decode<T>(_ type: DecodableDefault.Wrapper<T>.Type,
                 forKey key: Key) throws -> DecodableDefault.Wrapper<T> {
    try decodeIfPresent(type, forKey: key) ?? .init()
  }
}

public extension DecodableDefault {
  typealias Source = DecodableDefaultSource
  typealias List = Decodable & ExpressibleByArrayLiteral
  typealias Map = Decodable & ExpressibleByDictionaryLiteral
  
  enum Sources {
    public enum True: Source {
      public static var defaultValue: Bool { true }
    }
    
    public enum False: Source {
      public static var defaultValue: Bool { false }
    }
    
    public enum EmptyString: Source {
      public static var defaultValue: String { "" }
    }
    
    public enum EmptyList<T: List>: Source {
      public static var defaultValue: T { [] }
    }
    
    public enum EmptyMap<T: Map>: Source {
      public static var defaultValue: T { [:] }
    }
  }
}

public extension DecodableDefault {
  typealias True = Wrapper<Sources.True>
  typealias False = Wrapper<Sources.False>
  typealias EmptyString = Wrapper<Sources.EmptyString>
  typealias EmptyList<T: List> = Wrapper<Sources.EmptyList<T>>
  typealias EmptyMap<T: Map> = Wrapper<Sources.EmptyMap<T>>
}

extension DecodableDefault.Wrapper: Equatable where Value: Equatable {}
extension DecodableDefault.Wrapper: Hashable where Value: Hashable {}

extension DecodableDefault.Wrapper: Encodable where Value: Encodable {
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(wrappedValue)
  }
}

//example:
//struct Article: Decodable {
//  var title: String
//  @DecodableDefault.EmptyString var body: String
//  @DecodableDefault.False var isFeatured: Bool
//  @DecodableDefault.True var isActive: Bool
//  @DecodableDefault.EmptyList var comments: [Comment]
//  @DecodableDefault.EmptyMap var flags: [String : Bool]
//}
