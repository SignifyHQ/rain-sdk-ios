import Foundation

// sourcery: AutoMockable
public protocol CryptoChartRepositoryProtocol {
  func getCMCSymbolHistories(symbol: String, period: String) async throws -> [CMCSymbolHistoriesEntity]
}
