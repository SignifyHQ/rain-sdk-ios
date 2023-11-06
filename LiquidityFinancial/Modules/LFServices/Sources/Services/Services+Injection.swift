import Foundation
import Factory

@MainActor
extension Container {
  
  public var customerSupportService: Factory<CustomerSupportServiceProtocol> {
    self {
      IntercomService()
    }.singleton
  }
  
  public var vaultService: Factory<VaultServiceProtocol> {
    self {
      VaultService(
        vgsID: LFServices.vgsConfig.id,
        vgsENV: LFServices.vgsConfig.env
      )
    }
  }
  
}
