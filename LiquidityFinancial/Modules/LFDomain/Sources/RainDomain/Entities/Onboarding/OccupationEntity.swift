import Foundation

public protocol OccupationEntity: Decodable {
  var code: String { get }
  var occupation: String { get }
}
