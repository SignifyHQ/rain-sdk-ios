import Foundation
import Factory
import CoreNetwork
import BankDomain

extension Container {
  public var netspendAPI: Factory<NSPersonsAPIProtocol> {
    self { LFCoreNetwork<NSPersonsRoute>() }
  }
  
  public var nsPersionRepository: Factory<NSPersonsRepository> {
    self { NSPersonsRepository(netSpendAPI: self.netspendAPI.callAsFunction()) }
  }
  
  public var netspendDataManager: Factory<NetSpendDataManagerProtocol> {
    self { NetSpendDataManager() }.singleton
  }
}
