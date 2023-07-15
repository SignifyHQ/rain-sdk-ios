import Foundation

// MARK: - Appliable
public protocol Appliable {}

public extension Appliable {
  /// - Parameter configure: The configuration block to apply.
  @discardableResult
  func apply(_ configure: (Self) throws -> Void) rethrows -> Self {
    try configure(self)
    return self
  }
}

// MARK: - Appliable: Array
public extension Array where Element: Appliable {
  /// - Parameter configure: The configuration block to apply.
  @discardableResult
  func apply(_ configure: (Element) throws -> Void) rethrows -> Array {
    try forEach {
      try $0.apply(configure)
    }
    
    return self
  }
}

// MARK: - MutableAppliable
public protocol MutableAppliable {}

public extension MutableAppliable {
  /// A convenience function to apply styles using block based api.
  ///
  /// - Parameter configure: The configuration block to apply.
  @discardableResult
  func applying(_ configure: (inout Self) throws -> Void) rethrows -> Self {
    var object = self
    try configure(&object)
    return object
  }
  
  /// A convenience function to apply styles using block based api.
  ///
  /// - Parameter configure: The configuration block to apply.
  mutating func apply(_ configure: (inout Self) throws -> Void) rethrows {
    var object = self
    try configure(&object)
    self = object
  }
}

// MARK: - MutableAppliable: Array
public extension Array where Element: MutableAppliable {
  /// - Parameter configure: The configuration block to apply.
  @discardableResult
  func applying(_ configure: (inout Element) throws -> Void) rethrows -> Array {
    try forEach {
      try $0.applying(configure)
    }
    
    return self
  }
  
  /// A convenience function to apply styles using block based api.
  ///
  /// ```swift
  /// let label = UILabel()
  /// let button = UIButton()
  ///
  /// // later somewhere in the code
  /// [label, button].apply {
  ///     $0.isUserInteractionEnabled = false
  /// }
  ///
  /// // or
  /// let components = [UILabel(), UIButton()].apply {
  ///     $0.isUserInteractionEnabled = false
  /// }
  /// ```
  ///
  /// - Parameter configure: The configuration block to apply.
  mutating func apply(_ configure: (inout Element) throws -> Void) rethrows {
    for var item in self {
      try item.apply(configure)
    }
  }
}

// MARK: - NSObject + Appliable
extension NSObject: Appliable {}
