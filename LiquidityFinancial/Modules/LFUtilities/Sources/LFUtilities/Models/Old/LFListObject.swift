import Foundation

public protocol LFListObject {
  associatedtype Item
  var total: Int { get }
  var data: [Item] { get }
}

  // MARK: - ListResponse
public struct APIListObject<Element: Codable>: LFListObject {
  public var total: Int
  public var data: [Element]
}

  // MARK: Codable
extension APIListObject: Codable {
  public init(from decoder: Decoder) throws {
    let container: KeyedDecodingContainer<APIListObject<Element>.CodingKeys> = try decoder.container(keyedBy: APIListObject<Element>.CodingKeys.self)
    total = (try? container.decode(Int.self, forKey: APIListObject<Element>.CodingKeys.total)) ?? 1
      // Lenient strategy to parse the valid elements and ignore corrupted ones.
    let optionalData = try container.decode([OptionalElement<Element>].self, forKey: APIListObject<Element>.CodingKeys.data)
    data = optionalData.compactMap(\.value)
  }
}

  // MARK: - OptionalElement
private enum OptionalElement<T: Decodable>: Decodable {
  case success(T)
  case failure(Error)
  
  init(from decoder: Decoder) throws {
    do {
      let decoded = try T(from: decoder)
      self = .success(decoded)
    } catch {
      self = .failure(error)
    }
  }
  
  var value: T? {
    switch self {
    case .failure:
      return nil
    case let .success(value):
      return value
    }
  }
}
