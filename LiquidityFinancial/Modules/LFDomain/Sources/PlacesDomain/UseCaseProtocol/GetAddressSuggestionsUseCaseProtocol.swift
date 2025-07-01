import Foundation

public protocol GetAddressSuggestionsUseCaseProtocol {
  func execute(
    query: String
  ) async throws -> [PlaceSuggestionEntity]
}
