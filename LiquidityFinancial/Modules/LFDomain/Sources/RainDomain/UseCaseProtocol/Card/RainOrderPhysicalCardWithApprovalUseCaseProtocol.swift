import Foundation

public protocol RainOrderPhysicalCardWithApprovalUseCaseProtocol {
  func execute(parameters: RainOrderCardParametersEntity) async throws -> RainCardOrderEntity
}
