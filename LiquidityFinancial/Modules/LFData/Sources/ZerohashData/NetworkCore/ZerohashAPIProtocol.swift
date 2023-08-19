import Foundation
import NetworkUtilities
import LFUtilities
import AccountData

public protocol ZerohashAPIProtocol {
  func sendCrypto(accountId: String, destinationAddress: String, amount: Double) async throws -> APITransaction
}
