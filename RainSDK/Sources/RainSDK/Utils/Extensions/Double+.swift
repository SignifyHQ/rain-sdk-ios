import Foundation

extension Double {
  var weiToEth: Double {
    self / pow(10, 18)
  }
  
  var ethToWei: Double {
    self * pow(10, 18)
  }
  
  var toHexString: String {
    "0x" + String(Int(self), radix: 16)
  }
}
