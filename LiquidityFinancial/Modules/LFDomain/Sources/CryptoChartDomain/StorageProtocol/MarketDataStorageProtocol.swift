import Foundation
import Combine

public protocol MarketDataStorageProtocol {
  func subscribeLineModelsChanged(_ completion: @escaping ([String]) -> Void) -> Cancellable
}
