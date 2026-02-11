import Foundation
import Factory

@MainActor
extension Container {
  
  public var customerSupportService: Factory<CustomerSupportServiceProtocol> {
    self {
      CustomerSupportService()
    }.singleton
  }
  
  public var portalService: Factory<PortalServiceProtocol> {
    self {
      RainSDKService(base: PortalService())
    }
    .singleton
  }
  
  public var meshService: Factory<MeshServiceProtocol> {
    self {
      MeshService()
    }
    .singleton
  }
  
  public var rainService: Factory<RainServiceProtocol> {
    self {
      RainService()
    }
    .singleton
  }
  
  public var cloudKitService: Factory<CloudKitServiceProtocol> {
    self {
      CloudKitService()
    }
    .singleton
  }
  
}
