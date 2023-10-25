import Foundation
import Combine

// sourcery: AutoMockable
public protocol MarketDataStorageProtocol {
  func subscribeLineModelsChanged(_ completion: @escaping ([String]) -> Void) -> Cancellable
}
