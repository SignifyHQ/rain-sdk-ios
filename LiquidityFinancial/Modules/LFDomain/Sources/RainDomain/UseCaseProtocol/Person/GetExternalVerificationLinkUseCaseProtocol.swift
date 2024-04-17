import Foundation

public protocol GetExternalVerificationLinkUseCaseProtocol {
  func execute() async throws -> RainExternalVerificationLinkEntity
}
