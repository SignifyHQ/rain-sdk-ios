import Foundation
import LFUtilities

struct ACHModel {
  let accountNumber: String
  let routingNumber: String
  let accountName: String
  
  static let `default` = ACHModel(
    accountNumber: Constants.Default.undefined.rawValue,
    routingNumber: Constants.Default.undefined.rawValue,
    accountName: Constants.Default.undefined.rawValue
  )
}
