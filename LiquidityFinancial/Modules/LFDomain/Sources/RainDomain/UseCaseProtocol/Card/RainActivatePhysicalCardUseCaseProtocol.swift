import Foundation

public protocol RainActivatePhysicalCardUseCaseProtocol {
  func execute(cardID: String, parameters: RainActivateCardParametersEntity) async throws
}
