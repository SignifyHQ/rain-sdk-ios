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
  
  public func acceptTerms() async throws {
    try await rainAPI.acceptTerms()
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
  
  public func getCollateralContract() async throws -> RainCollateralContractEntity {
    try await rainAPI.getCollateralContract()
  }
  
  public func getCreditBalance() async throws -> RainCreditBalanceEntity {
    try await rainAPI.getCreditBalance()
  }
  
  public func getWithdrawalSignature(parameters: RainWithdrawalSignatureParametersEntity) async throws -> RainWithdrawalSignatureEntity {
    guard let parameters = parameters as? APIRainWithdrawalSignatureParameters else {
      throw "Can't map paramater :\(parameters)"
    }
    return try await rainAPI.getWithdrawalSignature(parameters: parameters)
  }
}
