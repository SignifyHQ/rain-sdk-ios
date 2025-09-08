import Foundation

public protocol RainOrderPhysicalCardUseCaseProtocol {
  func execute(parameters: RainOrderCardParametersEntity, shouldBeApproved: Bool) async throws -> RainCardEntity
}
