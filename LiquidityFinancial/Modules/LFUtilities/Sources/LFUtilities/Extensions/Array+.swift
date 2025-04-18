import Foundation

extension Array {
  
  public var isNotEmpty: Bool {
    !self.isEmpty
  }
  
  public var nilIfEmpty: Array? {
    self.isNotEmpty ? self : nil
  }
}
