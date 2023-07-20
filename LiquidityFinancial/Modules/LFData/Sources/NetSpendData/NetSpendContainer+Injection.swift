import Foundation
import Factory
import LFNetwork

extension Container {
  public var netspendAPI: Factory<NetSpendAPIProtocol> {
    self { LFNetwork<NetSpendRoute>() }
  }
  
  public var netspendRepository: Factory<NetSpendRepositoryProtocol> {
    self { NetSpendRepository(netSpendAPI: self.netspendAPI.callAsFunction()) }
  }
  
  public var netspendDataManager: Factory<NetSpendDataManagerProtocol> {
    self { NetSpendDataManager() }.singleton
  }
}
