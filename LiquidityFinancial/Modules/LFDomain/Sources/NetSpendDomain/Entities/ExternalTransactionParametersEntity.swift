import Foundation

public protocol ExternalTransactionParametersEntity {
  var amount: Double { get }
  var sourceId: String { get }
  var sourceType: String { get }
}

public protocol ExternalTransactionTypeEntity {
  static var deposit: Self { get }
  static var withdraw: Self { get }
  
  var rawString: String { get }
}
