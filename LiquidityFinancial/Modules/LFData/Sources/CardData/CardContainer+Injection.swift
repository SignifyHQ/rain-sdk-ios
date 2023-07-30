import Foundation
import Factory
import CardDomain
import LFNetwork

extension Container {
  public var cardAPI: Factory<CardAPIProtocol> {
    self {
      LFNetwork<CardRoute>()
    }
  }
  
  public var cardRepository: Factory<CardRepositoryProtocol> {
    self {
      CardRepository(cardAPI: self.cardAPI.callAsFunction())
    }
  }
}
