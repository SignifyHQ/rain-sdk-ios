import Combine
import Foundation
import Services

public protocol PortalStorageProtocol {
  var erc20Token: PortalToken? { get }
  func cryptoAssets() -> AnyPublisher<[PortalAsset], Never>
  func cryptoAsset(with symbol: String) -> AnyPublisher<PortalAsset?, Never>
  func update(walletAddress: String?, balances: [String: Double])
  func checkTokenSupport(with address: String) -> Bool
}
