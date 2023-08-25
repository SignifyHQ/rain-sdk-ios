import Foundation

  // MARK: - Sticker

public struct StickerModel: Hashable, Identifiable {
  public let id: String
  public let name: String
  public let url: URL?
  public let count: Int?
  public let backgroundColor: String?
  public let charityName: String?
  
  public init(id: String, name: String, url: URL?, count: Int?, backgroundColor: String?, charityName: String?) {
    self.id = id
    self.name = name
    self.url = url
    self.count = count
    self.backgroundColor = backgroundColor
    self.charityName = charityName
  }
}

extension StickerModel: Codable {
  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(String.self, forKey: .id)
    name = try container.decode(String.self, forKey: .name)
    url = try container.decodeUrl(forKey: .url)
    count = try container.decodeIfPresent(Int.self, forKey: .count)
    backgroundColor = try container.decodeIfPresent(String.self, forKey: .backgroundColor)
    charityName = try container.decodeIfPresent(String.self, forKey: .charityName)
  }
}
