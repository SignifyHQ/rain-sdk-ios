import Foundation

public protocol PinWheelTokenEntity {
  var id: String { get }
  var expires: String { get }
  var mode: String { get }
  var token: String { get }
}
