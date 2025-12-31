import Foundation
import LFStyleGuide
import SwiftUI

public enum ChartOption: String, CaseIterable {
  case candlestick
  case line
}

// MARK: - Identifiable

extension ChartOption: Identifiable {
  public var id: String {
    rawValue
  }
}

// MARK: - UI Helpers

extension ChartOption {
  var iconName: Image {
    switch self {
    case .candlestick:
      return GenImages.CommonImages.candleStick.swiftUIImage
    case .line:
      return GenImages.CommonImages.lineChart.swiftUIImage
    }
  }
}
