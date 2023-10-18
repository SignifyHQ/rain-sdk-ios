import Foundation

public protocol ACHInfoEntity {
  var bankName: String? { get }
  var bankAddress: String? { get }
  var accountNumber: String? { get }
  var routingNumber: String? { get }
  var accountName: String? { get }
}
