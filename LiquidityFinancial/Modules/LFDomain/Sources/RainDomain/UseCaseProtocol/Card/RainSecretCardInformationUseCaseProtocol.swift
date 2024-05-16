import Foundation

public protocol RainSecretCardInformationUseCaseProtocol {
  func execute(sessionID: String, cardID: String) async throws -> RainSecretCardInformationEntity
}
