import Foundation
import RainDomain

public class RainRepository: RainRepositoryProtocol {
  private let rainAPI: RainAPIProtocol
  
  public init(rainAPI: RainAPIProtocol) {
    self.rainAPI = rainAPI
  }
  
  public func getOnboardingMissingSteps() async throws -> RainOnboardingMissingStepsEntity {
    try await rainAPI.getOnboardingMissingSteps()
  }
  
  public func createRainAccount(parameters: RainPersonParametersEntity) async throws -> RainPersonEntity {
    guard let parameters = parameters as? APIRainPersonParameters else {
      throw "Can't map paramater :\(parameters)"
    }
    return try await rainAPI.createRainAccount(parameters: parameters)
  }
  
  public func getExternalVerificationLink() async throws -> RainExternalVerificationLinkEntity {
    try await rainAPI.getExternalVerificationLink()
  }
  
  public func getSmartContracts() async throws -> [RainSmartContractEntity] {
    try await rainAPI.getSmartContracts()
  }
}
