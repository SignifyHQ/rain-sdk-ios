import SwiftUI

public class CandleChartProperties: ObservableObject {
  @Published var lineWidth: CGFloat = 2.0
  @Published var bodyWidth: CGFloat = 4.0
  @Published var backgroundGradient: ColorGradient?
  @Published var negativeGradient: ColorGradient?
  @Published var positiveGradient: ColorGradient?
  @Published var gridColor: Color = .white
  @Published var showGridXLines: Bool = false
  @Published var showGridYLines: Bool = false
  @Published var gridYCount: Int = 5
  @Published var gridYBaseWidth: CGFloat = 60

  public init() {
    // no-op
  }
}
