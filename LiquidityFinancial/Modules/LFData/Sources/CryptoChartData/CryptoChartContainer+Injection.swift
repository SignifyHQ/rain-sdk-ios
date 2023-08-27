import Foundation
import Factory
import CoreNetwork
import CryptoChartDomain

extension Container {
  public var marketManager: Factory<MarketManager> {
    self { MarketManager() }.singleton
  }
  
  public var cryptoChartAPI: Factory<CryptoChartAPIProtocol> {
    self {
      LFCoreNetwork<CryptoChartRoute>()
    }
  }
  
  public var cryptoChartRepository: Factory<CryptoChartRepositoryProtocol> {
    self {
      CryptoChartRepository(
        cryptoChartAPI: self.cryptoChartAPI.callAsFunction(),
        auth: self.authorizationManager.callAsFunction()
      )
    }
  }
}
