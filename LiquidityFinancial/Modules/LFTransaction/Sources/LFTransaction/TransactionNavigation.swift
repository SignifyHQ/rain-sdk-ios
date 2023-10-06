import Foundation
import Factory
import LFUtilities
import SwiftUI

@MainActor
extension Container {
  
  public var transactionNavigation: Factory<TransactionNavigation> {
    self {
      TransactionNavigation()
    }.shared
  }
  
}

public final class TransactionNavigation {
  
  enum Destination: String {
  case currentReward = "CurrentReward"
  case addBankDebit = "AddBankDebit"
  }
  
  var services: [String: Any.Type] = [:]
  
  public init() {}
  
  var container: DIContainerAnyView!
  public func setup(container: DIContainerAnyView) {
    self.container = container
  }
  
  public func registerCurrentReward(type: Any.Type, factory: @escaping (DIContainerAnyView) -> AnyView) {
    services[Destination.currentReward.rawValue] = type
    container.register(type: type, name: Destination.currentReward.rawValue, factory: factory)
  }
  
  public func resolveCurrentReward() -> AnyView? {
    guard let type = services[Destination.currentReward.rawValue] else { return nil }
    return container.resolve(type: type, name: Destination.currentReward.rawValue)
  }
  
  public func registerAddBankDebit(type: Any.Type, factory: @escaping (DIContainerAnyView) -> AnyView) {
    services[Destination.addBankDebit.rawValue] = type
    container.register(type: type, name: Destination.addBankDebit.rawValue, factory: factory)
  }
  
  public func resolveAddBankDebit() -> AnyView? {
    guard let type = services[Destination.addBankDebit.rawValue] else { return nil }
    return container.resolve(type: type, name: Destination.addBankDebit.rawValue)
  }
}
