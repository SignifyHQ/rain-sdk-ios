import Foundation

public protocol GetAutofillAddressUseCaseProtocol {
  func execute(
    placeId: String
  ) async throws -> AutofillAddressEntity
}
