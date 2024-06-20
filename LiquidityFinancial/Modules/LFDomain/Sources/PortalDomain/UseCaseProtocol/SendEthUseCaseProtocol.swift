import Foundation

public protocol SendEthUseCaseProtocol {
  func execute(to address: String, contractAddress: String?, amount: Double) async throws -> String
}
