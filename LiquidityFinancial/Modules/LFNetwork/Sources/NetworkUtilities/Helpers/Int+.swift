import Foundation

public extension Int {
  var isSuccess: Bool {
    [
      200, // OK
      201, // Created
      202, // Accepted
      203, // Non-Authoritative Information
      204  // No Content
    ].contains(self)
  }
}
