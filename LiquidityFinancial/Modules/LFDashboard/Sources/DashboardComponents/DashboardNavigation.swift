import Foundation
import Factory
import LFUtilities
import SwiftUI

@MainActor
extension Container {
  
  public var dashboardNavigation: Factory<DashboardNavigation> {
    self {
      DashboardNavigation()
    }.shared
  }
  
}

public struct DisputeTransactionParameters {
  public let id: String
  public let passcode: String
  public let onClose: (() -> Void)
}

public final class DashboardNavigation {
  
  enum Destination: String {
    case disputeTransactionView
  }
  
  var services: [String: Any.Type] = [:]
  
  public var disputeTransactionParameters: DisputeTransactionParameters?
  
  public init() {}
  
  var container: DIContainerAnyView!
  public func setup(container: DIContainerAnyView) {
    self.container = container
  }
  
  public func registerDisputeTransactionView(type: Any.Type, factory: @escaping (DIContainerAnyView) -> AnyView) {
    services[Destination.disputeTransactionView.rawValue] = type
    container.register(type: type, name: Destination.disputeTransactionView.rawValue, factory: factory)
  }
  
  public func resolveDisputeTransactionView(id: String, passcode: String, onClose: @escaping (() -> Void)) -> AnyView? {
    disputeTransactionParameters = DisputeTransactionParameters(id: id, passcode: passcode, onClose: onClose)
    guard let type = services[Destination.disputeTransactionView.rawValue] else { return nil }
    container.clear(type: type, name: Destination.disputeTransactionView.rawValue)
    return container.resolve(type: type, name: Destination.disputeTransactionView.rawValue)
  }
}
