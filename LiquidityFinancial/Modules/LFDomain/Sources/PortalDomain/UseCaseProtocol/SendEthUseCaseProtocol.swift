import Foundation

public protocol SendEthUseCaseProtocol {
  func estimateFee(to address: String, contractAddress: String?, amount: Double) async throws -> Double
  func executeSend(to address: String, contractAddress: String?, amount: Double) async throws
}
