import Foundation

public protocol ExternalCardResponseEntity: Codable {
  var cardId: String { get }
}
