import Foundation
import SwiftUI

typealias Factory = (DIContainerAnyView) -> AnyView

protocol ServiceEntryProtocol: AnyObject {
  var factory: Factory { get }
  var instance: AnyView? { get set }
}

public final class ServiceEntry: ServiceEntryProtocol {
  var instance: AnyView?
  
  var factory: Factory
  weak var container: DIContainerAnyView?
  
  init(factory: @escaping Factory) {
    self.factory = factory
  }
}

public final class DIContainerAnyView {
  internal var services: [String: ServiceEntryProtocol] = [:]
  public init() {}
  
  public func register(type: Any.Type, name: String, factory: @escaping (DIContainerAnyView) -> AnyView) {
    let entry = ServiceEntry(factory: factory)
    entry.container = self
    let key = "\(type)\(name)"
    services[key] = entry
  }
  
  public func resolve(type: Any.Type, name: String) -> AnyView? {
    let key = "\(type)\(name)"
    if let entry = services[key] {
      var resolvedService: AnyView
      if let instance = entry.instance {
        resolvedService = instance
      } else {
        resolvedService = entry.factory(self)
        entry.instance = resolvedService
      }
      return resolvedService
    }
    return nil
  }
  
  @discardableResult
  public func clear(type: Any.Type, name: String) -> Bool {
    let key = "\(type)\(name)"
    if let entry = services[key] {
      entry.instance = nil
      return true
    }
    return false
  }
}
