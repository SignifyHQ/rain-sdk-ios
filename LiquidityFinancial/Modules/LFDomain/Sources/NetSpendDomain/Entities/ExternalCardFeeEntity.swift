import Foundation

public protocol ExternalCardFeeEntity: Codable {
  var id: String { get }
  var currency: String { get }
  var amount: Double { get }
  var memo: String { get }
}
