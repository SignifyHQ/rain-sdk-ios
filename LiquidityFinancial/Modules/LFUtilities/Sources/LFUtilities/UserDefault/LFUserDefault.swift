import Foundation
import UIKit

// swiftlint:disable all
@propertyWrapper
public struct LFUserDefault<T: PropertyListValue> {
  
  public let key: Key
    
  public let defaultValue: T
  
  public let parameter: String
  
  public let suiteName: String?
  
  public var wrappedValue: T {
    get { container.value(forKey: dynamicKey) as? T ?? defaultValue }
    set { container.set(newValue, forKey: dynamicKey) }
  }
  
  public var isExist: Bool {
    container.object(forKey: dynamicKey) != nil
  }
  
  public var projectedValue: LFUserDefault<T> { self }
  
  var container: UserDefaults {
    guard let suiteName
    else {
      return .standard
    }
    
    return .init(suiteName: suiteName) ?? .standard
  }

  public init(
    key: Key,
    defaultValue: T,
    parameter: String = .empty,
    suiteName: String? = nil
  ) {
    self.key = key
    self.defaultValue = defaultValue
    self.parameter = parameter
    self.suiteName = suiteName
  }

  public func observe(change: @escaping (T?, T?) -> Void) -> NSObject {
    UserDefaultsObservation(key: Key(stringLiteral: dynamicKey)) { old, new in
      change(old as? T, new as? T)
    }
  }
  
  private var dynamicKey: String {
    if parameter.isEmpty {
      return key.rawValue
    }
    return "\(key.rawValue)_for_\(parameter)"
  }
}

// The marker protocol
public protocol PropertyListValue {}

extension Data: PropertyListValue {}
extension String: PropertyListValue {}
extension Date: PropertyListValue {}
extension Bool: PropertyListValue {}
extension Int: PropertyListValue {}
extension Double: PropertyListValue {}
extension Float: PropertyListValue {}
extension CGFloat: PropertyListValue {}
extension CGSize: PropertyListValue {}

// Every element must be a property-list type
extension Array: PropertyListValue where Element: PropertyListValue {}
extension Dictionary: PropertyListValue where Key == String, Value: PropertyListValue {}

class UserDefaultsObservation: NSObject {
  let key: Key
  private var onChange: (Any, Any) -> Void

  init(key: Key, onChange: @escaping (Any, Any) -> Void) {
    self.onChange = onChange
    self.key = key
    super.init()
    UserDefaults.standard.addObserver(self, forKeyPath: key.rawValue, options: [.old, .new], context: nil)
  }

  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
    guard let change = change, object != nil, keyPath == key.rawValue else { return }
    onChange(change[.oldKey] as Any, change[.newKey] as Any)
  }

  deinit {
    UserDefaults.standard.removeObserver(self, forKeyPath: key.rawValue, context: nil)
  }
}

public struct Key: RawRepresentable {
  public let rawValue: String
  public init(rawValue: String) {
    self.rawValue = rawValue
  }
}

extension Key: ExpressibleByStringLiteral {
  public init(stringLiteral: String) {
    rawValue = stringLiteral
  }
}

// swiftlint:enabled all
