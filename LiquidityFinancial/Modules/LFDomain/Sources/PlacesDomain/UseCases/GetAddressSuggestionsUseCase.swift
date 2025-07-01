import Foundation
import GooglePlacesSwift

public final class GetAddressSuggestionsUseCase: GetAddressSuggestionsUseCaseProtocol {
  private let repository: PlacesRepositoryProtocol
  
  public init(
    repository: PlacesRepositoryProtocol
  ) {
    self.repository = repository
  }
  
  public func execute(
    query: String
  ) async throws -> [PlaceSuggestionEntity] {
    try await repository.getSuggestions(for: query)
  }
}
