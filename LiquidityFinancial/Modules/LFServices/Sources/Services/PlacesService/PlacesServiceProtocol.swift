import Foundation
import GooglePlacesSwift

public protocol PlacesServiceProtocol {
  func getSuggestions(
    for query: String
  ) async throws -> [AutocompleteSuggestion]
  
  func getAddressDetails(
    id: String
  ) async throws -> Place
  
  func getAddressFields(
    from components: [AddressComponent]
  ) -> (
    street: String?, city: String?, state: String?,
    postalCode: String?, country: String?
  )
}
