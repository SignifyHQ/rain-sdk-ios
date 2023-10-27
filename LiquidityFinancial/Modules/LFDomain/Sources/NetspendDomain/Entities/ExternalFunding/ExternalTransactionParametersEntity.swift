import Foundation

// sourcery: AutoMockable
public protocol ExternalTransactionParametersEntity {
  var amount: Double { get }
  var sourceId: String { get }
  var sourceType: String { get }
  var m2mFeeRequestId: String? { get }
}

// sourcery: AutoMockable
public protocol ExternalTransactionTypeEntity {
  static var deposit: Self { get }
  static var withdraw: Self { get }
  
  var rawString: String { get }
}
