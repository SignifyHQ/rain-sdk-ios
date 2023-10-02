import Foundation

public extension Optional where Wrapped == String {
  var orEmpty: String {
    self ?? ""
  }
}
