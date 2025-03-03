import Foundation

public extension Optional where Wrapped == String {
  var orEmpty: String {
    self ?? ""
  }
}

public extension Optional where Wrapped: Equatable {
  mutating func toggle(to value: Wrapped) {
    self = (self == value) ? nil : value
  }
}
