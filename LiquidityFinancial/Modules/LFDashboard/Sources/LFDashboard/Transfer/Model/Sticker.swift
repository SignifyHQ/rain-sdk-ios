import Foundation

// MARK: - Sticker

struct Sticker: Hashable, Identifiable {
  /// The identifier of this sticker.
  let id: String

  /// The name of the related fundraiser.
  let name: String

  /// The url to the sticker's asset.
  let url: URL?

  /// The count, if available, represents the amount of times the user has earned this sticker.
  let count: Int?

  /// The background color of the related fundraiser.
  let backgroundColor: String?

  /// The name of the related charity.
  let charityName: String?
}

// MARK: Codable

extension Sticker: Codable {
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(String.self, forKey: .id)
    name = try container.decode(String.self, forKey: .name)
    url = try container.decodeUrl(forKey: .url)
    count = try container.decodeIfPresent(Int.self, forKey: .count)
    backgroundColor = try container.decodeIfPresent(String.self, forKey: .backgroundColor)
    charityName = try container.decodeIfPresent(String.self, forKey: .charityName)
  }
}
