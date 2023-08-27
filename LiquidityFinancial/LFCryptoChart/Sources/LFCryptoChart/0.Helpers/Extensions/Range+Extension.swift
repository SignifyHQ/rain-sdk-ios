import Foundation

public extension ClosedRange where Bound: AdditiveArithmetic {
  var overreach: Bound {
    upperBound - lowerBound
  }
}

public extension ClosedRange where Bound == FloatLiteralType {
  func toIndexes(_ count: Int = 5, startOffset: Double = 0.1, endOffset: Double = 0.9) -> [(String, Double)] {
    let gridYCount = count
    let length = upperBound - lowerBound
    let minOffset = startOffset
    let maxOffset = endOffset
    let distanceOffset = (maxOffset - minOffset) / Double(gridYCount - 1)
    let indexes = Array(0 ..< gridYCount)
    let offsets: [Double] = indexes.map { index in
      Double(index) * distanceOffset + minOffset
    }
    return offsets.map { offset in
      (
        (lowerBound + length * offset).formattedAmount(minFractionDigits: 6, maxFractionDigits: 6),
        offset
      )
    }
  }
}
