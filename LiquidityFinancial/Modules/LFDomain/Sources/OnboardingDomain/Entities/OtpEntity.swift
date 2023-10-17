import Foundation

// sourcery: AutoMockable
public protocol OtpEntity {
  var requiredAuth: [String] { get }
  init(requiredAuth: [String])
}
