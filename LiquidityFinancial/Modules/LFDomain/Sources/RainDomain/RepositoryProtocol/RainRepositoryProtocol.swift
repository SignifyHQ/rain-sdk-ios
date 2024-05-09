import Foundation

// sourcery: AutoMockable
public protocol RainRepositoryProtocol {
  func getOnboardingMissingSteps() async throws -> RainOnboardingMissingStepsEntity
  func createRainAccount(parameters: RainPersonParametersEntity) async throws -> RainPersonEntity
  func getExternalVerificationLink() async throws -> RainExternalVerificationLinkEntity
  func getCollateralContract() async throws -> RainCollateralContractEntity
  func getCreditBalance() async throws -> RainCreditBalanceEntity
}
