import SwiftUI
import LFStyleGuide

public class LineChartProperties: ObservableObject {
  @Published var lineWidth: CGFloat = 2.0
  @Published var backgroundGradient: ColorGradient?
  @Published var showChartMarks: Bool = true
  @Published var customChartMarksColors: ColorGradient?
  @Published var lineStyle: LineStyle = .curved
  @Published var animationId: Int = 0
  @Published var indicatorColor: Color = Colors.primary.swiftUIColor
  @Published var indicatorBorderColor: Color = Colors.label.swiftUIColor
  @Published var highlightValueEnable: Bool = true
  @Published var showGridXLines: Bool = false
  @Published var showGridYLines: Bool = false
  @Published var gridColor: Color = Colors.label.swiftUIColor
  @Published var gridYBaseWidth: CGFloat = 60

  public init() {
    // no-op
  }
}
