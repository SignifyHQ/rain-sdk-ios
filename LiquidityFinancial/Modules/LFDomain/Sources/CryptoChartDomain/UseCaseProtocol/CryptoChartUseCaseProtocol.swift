import Foundation

protocol CryptoChartUseCaseProtocol {
  func execute(symbol: String, period: String) async throws -> [CMCSymbolHistoriesEntity]
}
