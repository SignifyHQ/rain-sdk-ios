import Foundation
import LFUtilities

struct Charity: Identifiable, Hashable {
  let id: String
  let name: String
  let description: String?
  let logo: URL?
  let header: URL?
  let url: URL?
  let ein: String
  let address: String?
  let navigatorUrl: URL?
  let emailUrl: URL?
  let twitterUrl: URL?
  let instagramUrl: URL?
  let facebookUrl: URL?
  let confidence: Int
  let isFeatured: Bool
}

// MARK: Codable

extension Charity: Codable {
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(String.self, forKey: .id)
    name = try container.decode(String.self, forKey: .name)
    description = try container.decodeIfPresent(String.self, forKey: .description)
    logo = try container.decodeUrl(forKey: .logo)
    header = try container.decodeUrl(forKey: .header)
    url = try container.decodeUrl(forKey: .url)
    ein = try container.decode(String.self, forKey: .ein)
    address = try container.decodeIfPresent(String.self, forKey: .address)
    navigatorUrl = try container.decodeUrl(forKey: .navigatorUrl)
    emailUrl = try container.decodeUrl(forKey: .emailUrl)
    twitterUrl = try container.decodeUrl(forKey: .twitterUrl)
    instagramUrl = try container.decodeUrl(forKey: .instagramUrl)
    facebookUrl = try container.decodeUrl(forKey: .facebookUrl)
    confidence = try container.decodeIfPresent(Int.self, forKey: .confidence) ?? 0
    isFeatured = try container.decodeIfPresent(Bool.self, forKey: .isFeatured) ?? false
  }

  enum CodingKeys: String, CodingKey {
    case id
    case name
    case description
    case logo
    case header
    case url
    case ein
    case address
    case navigatorUrl = "charityNavigatorUrl"
    case emailUrl = "emailListUrl"
    case twitterUrl
    case instagramUrl
    case facebookUrl
    case confidence
    case isFeatured
  }
}

extension Charity {
  // The API is returning a dummy Charity instead of returning null.
  // We need to manually ignore it so that the app doesn't show that a dummy charity is selected.
  var isValid: Bool {
    id != "00000000-0000-0000-0000-000000000000"
  }
}
