import Foundation

public extension Bool? {
  var falseIfNil: Bool {
    self ?? false
  }
}
