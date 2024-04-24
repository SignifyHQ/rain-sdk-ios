import Combine
import Foundation
import Services

public protocol PortalStorageProtocol {
  func cryptoAssets() -> AnyPublisher<[PortalAsset], Never>
  func cryptoAsset(with symbol: String) -> AnyPublisher<PortalAsset?, Never>
  func store(assets: [PortalAsset])
}
