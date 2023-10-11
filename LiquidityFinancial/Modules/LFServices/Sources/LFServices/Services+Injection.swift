import Foundation
import Factory

@MainActor
extension Container {
  
  public var customSupportService: Factory<CustomerSupportServiceProtocol> {
    self {
      IntercomService()
    }.singleton
  }
  
}
