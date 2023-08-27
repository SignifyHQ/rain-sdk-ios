import Foundation
import NetworkUtilities
import CoreNetwork
import LFUtilities

extension LFCoreNetwork: CryptoChartAPIProtocol where R == CryptoChartRoute {
  public func getCMCSymbolHistories(symbol: String, period: String) async throws -> [APICMCSymbolHistories] {
    let response = try await request(
      CryptoChartRoute.getCMCSymbolHistories(symbol: symbol, period: period),
      target: APIListObject<APICMCSymbolHistories>.self,
      failure: LFErrorObject.self,
      decoder: .apiDecoder
    )
    return response.data
  }
}
