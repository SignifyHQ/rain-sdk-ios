import Foundation

protocol GetCMCSymbolHistoriesUseCaseProtocol {
  func execute(symbol: String, period: String) async throws -> [CMCSymbolHistoriesEntity]
}
