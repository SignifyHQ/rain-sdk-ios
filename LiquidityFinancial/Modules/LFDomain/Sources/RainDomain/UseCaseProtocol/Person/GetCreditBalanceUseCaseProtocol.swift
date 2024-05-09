import Foundation

public protocol GetCreditBalanceUseCaseProtocol {
  func execute() async throws -> RainCreditBalanceEntity
}
