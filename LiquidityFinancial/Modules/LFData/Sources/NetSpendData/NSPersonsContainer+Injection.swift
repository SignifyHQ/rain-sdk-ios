import Foundation
import Factory
import LFNetwork

extension Container {
  public var netspendAPI: Factory<NSPersonsAPIProtocol> {
    self { LFNetwork<NSPersonsRoute>() }
  }
  
  public var netspendRepository: Factory<NSPersonsRepositoryProtocol> {
    self { NSPersonsRepository(netSpendAPI: self.netspendAPI.callAsFunction()) }
  }
  
  public var netspendDataManager: Factory<NetSpendDataManagerProtocol> {
    self { NetSpendDataManager() }.singleton
  }
}
