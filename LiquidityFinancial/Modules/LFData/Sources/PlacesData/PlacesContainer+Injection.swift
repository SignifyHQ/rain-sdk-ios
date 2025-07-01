import Factory
import Foundation
import PlacesDomain
import Services

extension Container {
  public var placesService: Factory<PlacesServiceProtocol> {
    self {
      PlacesService()
    }
    .singleton
  }
  
  public var placesRepository: Factory<PlacesRepositoryProtocol> {
    self {
      PlacesRepository(
        placesService: self.placesService.callAsFunction()
      )
    }
  }
}
