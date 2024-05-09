import Combine
import Factory
import Foundation
import LFUtilities
import PortalDomain
import Services

public class PortalStorage: PortalStorageProtocol {
  @LazyInjected(\.environmentService) var environmentService
  
  private var defaultCryptoAssets: [PortalAsset] = []
  private var cryptoAssetsSubject: CurrentValueSubject<[PortalAsset], Never> = CurrentValueSubject([])

  init() {
    // Setting assets which will be used by the app based on the environment
    defaultCryptoAssets = [
      PortalAsset(token: .AVAX),
      PortalAsset(token: environmentService.networkEnvironment == .productionTest ? .SepoliaUSDC : .MainnetAvalancheUSDC)
    ]
    
    // Make sure the assets are always visible because when user have no balance in some crypto asset, blockchain will not return any balance for it
    cryptoAssetsSubject.send(defaultCryptoAssets)
  }
  
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
  
  public func update(
    walletAddress: String?,
    balances: [String: Double]
  ) {
    let updatedAssets = defaultCryptoAssets
      .map { asset in
        PortalAsset(
          token: asset.token,
          balance: balances[asset.token.contractAddress],
          walletAddress: walletAddress
        )
      }
    
    cryptoAssetsSubject.send(updatedAssets)
  }
  
  public func checkTokenSupport(with address: String) -> Bool {
    defaultCryptoAssets.contains {
      $0.token.contractAddress == address
    }
  }

}
