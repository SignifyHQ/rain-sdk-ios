import Foundation
import AuthorizationManager
import LFUtilities
import CryptoChartDomain

public class CryptoChartRepository: CryptoChartRepositoryProtocol {
  
  private let cryptoChartAPI: CryptoChartAPIProtocol
  private let auth: AuthorizationManagerProtocol
  
  public init(cryptoChartAPI: CryptoChartAPIProtocol, auth: AuthorizationManagerProtocol) {
    self.cryptoChartAPI = cryptoChartAPI
    self.auth = auth
  }
  
  public func getCMCSymbolHistories(symbol: String, period: String) async throws -> [CMCSymbolHistoriesEntity] {
    try await cryptoChartAPI.getCMCSymbolHistories(symbol: symbol, period: period)
  }
}
