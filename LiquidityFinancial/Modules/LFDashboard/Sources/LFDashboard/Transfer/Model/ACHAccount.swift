import Foundation

struct ACHAccount: Codable {
  var accountNumber: String?
  var accountType: String?

  var last4accountnumber: String {
    guard let accountNum = accountNumber else {
      return ""
    }
    let last4accountnumber = String(accountNum.suffix(4))
    return last4accountnumber
  }
}
