import Foundation
import SwiftUI

public extension CGRect {
  /// Midpoint of rectangle
  /// - Returns: the coordinate for a rectangle center
  var mid: CGPoint {
    CGPoint(x: midX, y: midY)
  }
}
