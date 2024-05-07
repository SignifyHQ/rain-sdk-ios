import Foundation

public protocol GetSmartContractsUseCaseProtocol {
  func execute() async throws -> [RainSmartContractEntity]
}
