import Foundation
import PlacesDomain
import Services

public class PlacesRepository: PlacesRepositoryProtocol {
  private let placesService: PlacesServiceProtocol
  
  public init(
    placesService: PlacesServiceProtocol
  ) {
    self.placesService = placesService
  }
  
  public func getSuggestions(
    for query: String
  ) async throws -> [any PlacesDomain.PlaceSuggestionEntity] {
    let suggestions = try await placesService.getSuggestions(for: query)
    
    return suggestions.compactMap { autocompleteSuggestion in
      switch autocompleteSuggestion {
      case let .place(place):
        return PlaceSuggestion(
          placeId: place.placeID,
          title: place.legacyAttributedFullText.string
        )
      default:
        return nil
      }
    }
  }
  
  public func getAutofillAddress(
    for placeId: String
  ) async throws -> (any PlacesDomain.AutofillAddressEntity) {
    guard let addressComponents = try await placesService.getAddressDetails(id: placeId).addressComponents
    else {
      throw PlacesError.failedToParseAddress
    }
    
    let details = placesService.getAddressFields(from: addressComponents)
    
    return AutofillAddress(
      street: details.street,
      city: details.city,
      state: details.state,
      postalCode: details.postalCode,
      country: details.country
    )
  }
}
