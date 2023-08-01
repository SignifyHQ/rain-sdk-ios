import Foundation

  // MARK: - ListResponse

public struct ListEntity<T: Codable> {
  public var total: Int?
  public var data: [T]?
}

  // MARK: Codable

extension ListEntity: Codable {
  public init(from decoder: Decoder) throws {
    let container: KeyedDecodingContainer<ListEntity<T>.CodingKeys> = try decoder.container(keyedBy: ListEntity<T>.CodingKeys.self)
    total = try container.decode(Int.self, forKey: ListEntity<T>.CodingKeys.total)
    // Lenient strategy to parse the valid elements and ignore corrupted ones.
    let optionalData = try container.decode([OptionalElement<T>].self, forKey: ListEntity<T>.CodingKeys.data)
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
