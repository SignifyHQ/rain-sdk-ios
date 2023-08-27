import Foundation
import LFUtilities

protocol CryptoChartUseCaseProtocol {
  func execute(symbol: String, period: String) async throws -> [CMCSymbolHistoriesEntity]
}
