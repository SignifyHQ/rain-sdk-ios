import Foundation

// sourcery: AutoMockable
public protocol CryptoChartAPIProtocol {
  func getCMCSymbolHistories(symbol: String, period: String) async throws -> [APICMCSymbolHistories]
}
