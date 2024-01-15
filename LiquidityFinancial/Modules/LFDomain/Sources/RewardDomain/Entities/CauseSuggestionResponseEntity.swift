import Foundation

public protocol CauseSuggestionResponseEntity {
  var id: String { get }
  var userId: String { get }
  var suggestion: String { get }
  var createdAt: String { get }
  var updatedAt: String { get }
  var deletedAt: String? { get }
}
