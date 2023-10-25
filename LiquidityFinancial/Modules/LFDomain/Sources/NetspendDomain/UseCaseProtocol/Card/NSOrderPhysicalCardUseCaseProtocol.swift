import Foundation

public protocol NSOrderPhysicalCardUseCaseProtocol {
  func execute(
    address: AddressCardParametersEntity,
    sessionID: String
  ) async throws -> CardEntity
}
