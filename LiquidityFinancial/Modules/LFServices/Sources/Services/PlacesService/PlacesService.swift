import Foundation
import GooglePlacesSwift

public class PlacesService: PlacesServiceProtocol {
  public init() {}
  
  public func getSuggestions(
    for query: String
  ) async throws -> [AutocompleteSuggestion] {
    let autocompleteRequest = AutocompleteRequest(query: query)
    
    switch await PlacesClient.shared.fetchAutocompleteSuggestions(with: autocompleteRequest) {
    case .success(let autocompleteSuggestions):
      return autocompleteSuggestions
    case .failure(let placesError):
      throw placesError
    }
  }
  
  public func getAddressDetails(
    id: String
  ) async throws -> Place {
    let placeDetailsRequest = FetchPlaceRequest(placeID: id, placeProperties: [.addressComponents])
    
    let result = await PlacesClient.shared.fetchPlace(with: placeDetailsRequest)
    
    switch result {
    case .success(let place):
      return place
    case .failure(let error):
      throw error
    }
  }
  
  public func getAddressFields(
    from components: [AddressComponent]
  ) -> (
    street: String?, city: String?, state: String?,
    postalCode: String?, country: String?
  ) {
    var streetNumber: String?
    var route: String?
    var city: String?
    var state: String?
    var postalCode: String?
    var country: String?
    
    for component in components {
      if component.types.contains(.streetNumber) {
        streetNumber = component.name
      }
      if component.types.contains(.route) {
        route = component.name
      }
      if component.types.contains(.locality) {
        city = component.name
      }
      if component.types.contains(.administrativeAreaLevel1) {
        state = component.name
      }
      if component.types.contains(.postalCode) {
        postalCode = component.name
      }
      if component.types.contains(.country) {
        country = component.name
      }
    }
    
    let street = [streetNumber, route].compactMap { $0 }.joined(separator: " ")
    
    return (
      street: street.isEmpty ? nil : street,
      city: city,
      state: state,
      postalCode: postalCode,
      country: country
    )
  }
}
