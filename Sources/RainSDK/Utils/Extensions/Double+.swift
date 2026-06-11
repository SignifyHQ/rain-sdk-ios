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

  /// Shortest exact `Decimal` matching this value's printed form (e.g. `0.1` → `Decimal(string: "0.1")`).
  /// Use at `Double → Decimal` boundaries; avoids `Decimal(aDouble)`, which would capture the
  /// full float error (`Decimal(0.1)` is `0.10000000000000000555…`).
  var asDecimal: Decimal {
    Decimal(string: String(self)) ?? 0
  }
}
