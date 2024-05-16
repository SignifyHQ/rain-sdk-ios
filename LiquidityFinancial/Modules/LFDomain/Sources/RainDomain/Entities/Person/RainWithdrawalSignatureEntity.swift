import Foundation

// sourcery: AutoMockable
public protocol RainWithdrawalSignatureEntity {
  var data: String { get }
  var salt: String { get }
}
