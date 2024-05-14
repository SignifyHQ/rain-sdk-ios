import Foundation

public protocol RainOrderPhysicalCardUseCaseProtocol {
  func execute(parameters: RainOrderCardParametersEntity) async throws -> RainCardEntity
}
  
