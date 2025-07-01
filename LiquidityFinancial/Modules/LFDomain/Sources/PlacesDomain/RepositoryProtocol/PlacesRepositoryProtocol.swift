import Foundation
import GooglePlacesSwift

// sourcery: AutoMockable
public protocol PlacesRepositoryProtocol {
  func getSuggestions(for query: String) async throws -> [PlaceSuggestionEntity]
  func getAutofillAddress(for placeId: String) async throws -> AutofillAddressEntity
}
