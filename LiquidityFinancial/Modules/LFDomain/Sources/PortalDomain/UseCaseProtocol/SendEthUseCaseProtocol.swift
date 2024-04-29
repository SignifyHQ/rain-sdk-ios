import Foundation

public protocol SendEthUseCaseProtocol {
  func estimateFee(to address: String, amount: Double) async throws
  func executeSend(to address: String, amount: Double) async throws
}
