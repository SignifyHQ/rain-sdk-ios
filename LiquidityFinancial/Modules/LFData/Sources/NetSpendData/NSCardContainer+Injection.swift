import Foundation
import Factory
import BankDomain
import CoreNetwork

extension Container {
  public var cardAPI: Factory<NSCardAPIProtocol> {
    self {
      LFCoreNetwork<NSCardRoute>()
    }
  }
  
  public var cardRepository: Factory<NSCardRepositoryProtocol> {
    self {
      NSCardRepository(cardAPI: self.cardAPI.callAsFunction())
    }
  }
}
