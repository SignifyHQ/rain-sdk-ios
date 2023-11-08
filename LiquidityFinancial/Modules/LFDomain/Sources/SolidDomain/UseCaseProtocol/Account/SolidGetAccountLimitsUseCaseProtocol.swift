import Foundation

public protocol SolidGetAccountLimitsUseCaseProtocol {
  func execute() async throws -> SolidAccountLimitsEntity?
}
