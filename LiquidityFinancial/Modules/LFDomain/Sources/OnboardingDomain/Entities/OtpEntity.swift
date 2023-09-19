import Foundation

public protocol OtpEntity {
  var requiredAuth: [String] { get }
}
