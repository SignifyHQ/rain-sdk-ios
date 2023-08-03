import Foundation
import ObjectiveC.runtime

let swizzleDefaultSessionConfiguration: Void = {
  let defaultSessionConfiguration = class_getClassMethod(URLSessionConfiguration.self, #selector(getter: URLSessionConfiguration.default))
  let mockingjayDefaultSessionConfiguration = class_getClassMethod(URLSessionConfiguration.self, #selector(URLSessionConfiguration.mockingjayDefaultSessionConfiguration))
  method_exchangeImplementations(defaultSessionConfiguration!, mockingjayDefaultSessionConfiguration!)
}()


public extension URLSessionConfiguration {
  @objc class func mockingswizzleDefaultSessionConfiguration() {
    _ = swizzleDefaultSessionConfiguration
  }
  
  @objc class func mockingjayDefaultSessionConfiguration() -> URLSessionConfiguration {
    let configuration = mockingjayDefaultSessionConfiguration()
    configuration.protocolClasses = [DBCustomHTTPProtocol.self] as [AnyClass] + configuration.protocolClasses!
    return configuration
  }
}
