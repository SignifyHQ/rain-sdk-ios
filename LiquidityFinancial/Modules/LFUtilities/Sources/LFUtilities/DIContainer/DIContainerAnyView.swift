import Foundation
import SwiftUI

typealias Factory = (DIContainerAnyView) -> AnyView

protocol ServiceEntryProtocol: AnyObject{
  var factory: Factory { get }
  var instance: AnyView? { get set }
}

final public class ServiceEntry: ServiceEntryProtocol {
  var instance: AnyView?
  
  var factory: Factory
  weak var container: DIContainerAnyView?
  
  init(factory: @escaping Factory) {
    self.factory = factory
  }
}

final public class DIContainerAnyView {
  private var services: [String: ServiceEntryProtocol] = [:]
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
}
