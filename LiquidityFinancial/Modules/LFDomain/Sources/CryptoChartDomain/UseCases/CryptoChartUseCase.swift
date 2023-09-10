import Foundation

public final class CryptoChartUseCase: CryptoChartUseCaseProtocol {
  
  private let repository: CryptoChartRepositoryProtocol
  
  public init(repository: CryptoChartRepositoryProtocol) {
    self.repository = repository
  }

  public func execute(symbol: String, period: String) async throws -> [CMCSymbolHistoriesEntity] {
    try await repository.getCMCSymbolHistories(symbol: symbol, period: symbol)
  }
}
