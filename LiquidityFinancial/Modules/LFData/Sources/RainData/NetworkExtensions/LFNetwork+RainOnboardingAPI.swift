import Foundation
import NetworkUtilities
import CoreNetwork
import LFUtilities

extension LFCoreNetwork: RainAPIProtocol where R == RainRoute {
  public func getOnboardingMissingSteps() async throws -> APIRainOnboardingMissingSteps {
    let result = try await request(
      RainRoute.getOnboardingMissingSteps,
      target: [String].self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
    
    return APIRainOnboardingMissingSteps(processSteps: result)
  }
  
  public func acceptTerms() async throws {
    try await requestNoResponse(
      RainRoute.acceptTerms,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func createRainAccount(parameters: APIRainPersonParameters) async throws -> APIRainPerson {
    try await request(
      RainRoute.createAccount(parameters: parameters),
      target: APIRainPerson.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func getExternalVerificationLink() async throws -> APIRainExternalVerificationLink {
    try await request(
      RainRoute.getExternalVerificationLink,
      target: APIRainExternalVerificationLink.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func getCollateralContract() async throws -> APIRainCollateralContract {
    try await request(
      RainRoute.getCollateralContract,
      target: APIRainCollateralContract.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func getCreditBalance() async throws -> APIRainCreditBalance {
    try await request(
      RainRoute.getCreditBalance,
      target: APIRainCreditBalance.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
  
  public func getWithdrawalSignature(parameters: APIRainWithdrawalSignatureParameters) async throws -> APIRainWithdrawalSignature {
    try await request(
      RainRoute.getWithdrawalSignature(parameters: parameters),
      target: APIRainWithdrawalSignature.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
  }
}
