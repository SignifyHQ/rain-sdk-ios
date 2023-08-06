import Foundation
import Factory
import NetSpendDomain
import LFNetwork

extension Container {
  public var cardAPI: Factory<NSCardAPIProtocol> {
    self {
      LFNetwork<NSCardRoute>()
    }
  }
  
  public var cardRepository: Factory<NSCardRepositoryProtocol> {
    self {
      NSCardRepository(cardAPI: self.cardAPI.callAsFunction())
    }
  }
}
