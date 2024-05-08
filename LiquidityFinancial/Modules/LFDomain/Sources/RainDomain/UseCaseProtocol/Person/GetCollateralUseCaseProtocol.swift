import Foundation

public protocol GetCollateralUseCaseProtocol {
  func execute() async throws -> RainCollateralContractEntity
}
