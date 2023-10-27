import Foundation
  
public protocol NSGetPinWheelTokenUseCaseProtocol {
  func execute(sessionID: String) async throws -> PinWheelTokenEntity
}
