import Foundation
import Factory
import CoreNetwork

extension Container {
  public var netspendAPI: Factory<NSPersonsAPIProtocol> {
    self { LFCoreNetwork<NSPersonsRoute>() }
  }
  
  public var netspendRepository: Factory<NSPersonsRepositoryProtocol> {
    self { NSPersonsRepository(netSpendAPI: self.netspendAPI.callAsFunction()) }
  }
  
  public var netspendDataManager: Factory<NetSpendDataManagerProtocol> {
    self { NetSpendDataManager() }.singleton
  }
}
