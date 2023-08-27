import Foundation
import LFUtilities

public protocol CryptoChartRepositoryProtocol {
  func getCMCSymbolHistories(symbol: String, period: String) async throws -> [CMCSymbolHistoriesEntity]
}
