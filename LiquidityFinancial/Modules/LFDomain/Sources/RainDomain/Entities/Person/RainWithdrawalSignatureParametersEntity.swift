import Foundation

// sourcery: AutoMockable
public protocol RainWithdrawalSignatureParametersEntity {
  var chainId: Int { get }
  var token: String { get }
  var amount: String { get }
  var recipientAddress: String { get }
  var isAmountNative: Bool { get }
}
