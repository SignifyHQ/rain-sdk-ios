import Foundation

public protocol SolidCreatePinwheelTokenUseCaseProtocol {
  func execute(accountId: String) async throws -> SolidExternalPinwheelTokenResponseEntity
}
