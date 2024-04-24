import Combine
import Foundation
import Services

public protocol PortalStorageProtocol {
  func cryptoBalances() -> AnyPublisher<[PortalBalance], Never>
  func cryptoBalance(for symbol: String) -> AnyPublisher<PortalBalance?, Never>
  func store(balances: [PortalBalance])
}
