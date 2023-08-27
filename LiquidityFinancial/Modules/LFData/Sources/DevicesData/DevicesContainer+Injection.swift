import Foundation
import Factory
import DevicesDomain
import CoreNetwork
import AuthorizationManager

extension Container {
  public var devicesAPI: Factory<DevicesAPIProtocol> {
    self {
      LFCoreNetwork<DeviceRoute>()
    }
  }
  
  public var devicesRepository: Factory<DevicesRepositoryProtocol> {
    self { DevicesRepository(devicesAPI: self.devicesAPI.callAsFunction()) }
  }
}
