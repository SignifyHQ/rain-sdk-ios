import Foundation

// MARK: - Cause

struct Cause: Hashable, Identifiable {
  let id: String
  let name: String
  let logoUrl: URL?
  let rank: Int
}

// MARK: Codable

extension Cause: Codable {
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(String.self, forKey: .id)
    name = try container.decode(String.self, forKey: .name)
    logoUrl = try container.decodeUrl(forKey: .logoUrl)
    rank = try container.decode(Int.self, forKey: .rank)
  }
}
