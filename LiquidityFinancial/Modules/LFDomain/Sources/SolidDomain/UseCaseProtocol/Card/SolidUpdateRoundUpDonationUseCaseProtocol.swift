import Foundation

public protocol SolidUpdateRoundUpDonationUseCaseProtocol {
  func execute(cardID: String, parameters: SolidRoundUpDonationParametersEntity) async throws -> SolidCardEntity
}
