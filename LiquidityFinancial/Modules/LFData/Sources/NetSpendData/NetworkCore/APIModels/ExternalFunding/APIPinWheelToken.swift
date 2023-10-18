import Foundation
import BankDomain

public struct APIPinWheelToken: PinWheelTokenEntity, Decodable {
  public var id: String
  public var expires: String
  public var mode: String
  public var token: String
}
