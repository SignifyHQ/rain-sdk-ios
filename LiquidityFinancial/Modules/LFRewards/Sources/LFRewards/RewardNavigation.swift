import Foundation
import Factory
import LFUtilities
import SwiftUI

@MainActor
extension Container {
  
  public var rewardNavigation: Factory<RewardNavigation> {
    self {
      RewardNavigation()
    }.shared
  }
  
}

public final class RewardNavigation {
  
  enum Destination: String {
    case agreementView = "AgreementView"
  }
  
  var services: [String: Any.Type] = [:]
  
  public init() {}
  
  var container: DIContainerAnyView!
  public func setup(container: DIContainerAnyView) {
    self.container = container
  }
  
  public func registerAgreementView(type: Any.Type, factory: @escaping (DIContainerAnyView) -> AnyView) {
    services[Destination.agreementView.rawValue] = type
    container.register(type: type, name: Destination.agreementView.rawValue, factory: factory)
  }
  
  public func resolveAgreementView() -> AnyView? {
    guard let type = services[Destination.agreementView.rawValue] else { return nil }
    return container.resolve(type: type, name: Destination.agreementView.rawValue)
  }
}
