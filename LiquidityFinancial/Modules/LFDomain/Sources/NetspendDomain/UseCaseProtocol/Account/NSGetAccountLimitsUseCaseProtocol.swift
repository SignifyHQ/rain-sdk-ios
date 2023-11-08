import Foundation

public protocol NSGetAccountLimitsUseCaseProtocol {
  func execute() async throws -> any NSAccountLimitsEntity
}
