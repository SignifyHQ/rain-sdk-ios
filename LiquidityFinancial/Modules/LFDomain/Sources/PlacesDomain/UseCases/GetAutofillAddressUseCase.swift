import Foundation
import GooglePlacesSwift

public final class GetAutofillAddressUseCase: GetAutofillAddressUseCaseProtocol {
  private let repository: PlacesRepositoryProtocol
  
  public init(
    repository: PlacesRepositoryProtocol
  ) {
    self.repository = repository
  }
  
  public func execute(
    placeId: String
  ) async throws -> AutofillAddressEntity {
    try await repository.getAutofillAddress(for: placeId)
  }
}
