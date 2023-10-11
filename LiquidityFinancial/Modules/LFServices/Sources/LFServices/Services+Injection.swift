import Foundation
import Factory

@MainActor
extension Container {
  
  public var customerSupportService: Factory<CustomerSupportServiceProtocol> {
    self {
      IntercomService()
    }.singleton
  }
  
}
