import Combine
import Foundation
import PortalDomain
import Services

public class PortalStorage: PortalStorageProtocol {
  
  private var cryptoBalancesSubject: CurrentValueSubject<[PortalBalance], Never> = CurrentValueSubject([])
  
  public func cryptoBalances() -> AnyPublisher<[PortalBalance], Never> {
    cryptoBalancesSubject.eraseToAnyPublisher()
  }
  
  public func cryptoBalance(
    for symbol: String
  ) -> AnyPublisher<PortalBalance?, Never> {
    cryptoBalancesSubject
      .map { cryptoBalances in
        cryptoBalances.first { balance in
          balance.token.symbol == symbol
        }
      }
      .eraseToAnyPublisher()
  }
  
  public func store(
    balances: [PortalBalance]
  ) {
    cryptoBalancesSubject.send(balances)
  }
}
