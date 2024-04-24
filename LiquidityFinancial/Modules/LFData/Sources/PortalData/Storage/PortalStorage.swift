import Combine
import Foundation
import PortalDomain
import Services

public class PortalStorage: PortalStorageProtocol {
  
  private var cryptoAssetsSubject: CurrentValueSubject<[PortalAsset], Never> = CurrentValueSubject([])
  
  public func cryptoAssets() -> AnyPublisher<[PortalAsset], Never> {
    cryptoAssetsSubject.eraseToAnyPublisher()
  }
  
  public func cryptoAsset(
    with symbol: String
  ) -> AnyPublisher<PortalAsset?, Never> {
    cryptoAssetsSubject
      .map { cryptoAssets in
        cryptoAssets.first { asset in
          asset.token.symbol == symbol
        }
      }
      .eraseToAnyPublisher()
  }
  
  public func store(
    assets: [PortalAsset]
  ) {
    cryptoAssetsSubject.send(assets)
  }
}
