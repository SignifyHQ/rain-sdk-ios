import Foundation
import NetworkUtilities
import LFUtilities

public protocol CryptoChartAPIProtocol {
  func getCMCSymbolHistories(symbol: String, period: String) async throws -> [APICMCSymbolHistories]
}
