import Combine
import SwiftUI
import LFStyleGuide
import LFUtilities
import CryptoChartData
import Services

public struct CryptoChartView: View {
  @StateObject private var viewModel: CryptoChartViewModel
  @StateObject var lineChartValue = ChartValue()
  @StateObject var candleChartValue = ChartValue()
  
  public var properties = CryptoChartProperties()
  
  public init(
    filterOptionSubject: CurrentValueSubject<CryptoFilterOption, Never>,
    chartOptionSubject: CurrentValueSubject<ChartOption, Never>
  ) {
    _viewModel = .init(
      wrappedValue: .init(
        filterOptionSubject: filterOptionSubject,
        chartOptionSubject: chartOptionSubject
      )
    )
  }
  
  public var body: some View {
    VStack {
      chartView
      filterView
    }
    .background(Colors.background.swiftUIColor)
    .onAppear {
      viewModel.appearOperations()
      viewModel.setUp(lineChartValue: lineChartValue, candleChartValue: candleChartValue)
      viewModel.selectedHistoricalPriceSubject = properties.selectedHistoricalPriceSubject
    }
    .onDisappear {
      viewModel.disconnectSocket()
    }
    .track(name: String(describing: type(of: self)))
  }
  
  var lineChartView: some View {
    LineChart()
      .setLineStyle(to: .curved)
      .setLineWidth(width: 2)
      .showChartMarks(false)
      .setBackground(
        colorGradient: ColorGradient(
          Colors.chartTop.swiftUIColor,
          Colors.chartBottom.swiftUIColor
        )
      )
      .setGridColor(to: Color(white: 1.0, opacity: 0.15))
      .setIndicatorColor(to: Colors.primary.swiftUIColor)
      .setHighlightValueEnable(to: properties.highlightValueEnable)
      .setShowGridXLines(to: properties.gridXEnable)
      .setShowGridYLines(to: properties.gridYEnable)
      .data(viewModel.lineChartData)
      .rangeY(viewModel.lineChartRangeY)
      .gridXIndexes(viewModel.lineGridXIndexes)
      .gridYIndexes(viewModel.lineGridYIndexes)
      .chartStyle(
        ChartStyle(
          backgroundColor: .clear,
          foregroundColor: [ColorGradient(Colors.primary.swiftUIColor)]
        )
      )
      .environmentObject(lineChartValue)
  }
  
  var candlestickView: some View {
    CandleChart()
      .data(candleDatas: viewModel.candleChartData)
      .rangeY(rangeY: viewModel.candleChartRangeY)
      .rangeX(rangeX: viewModel.candleChartRangeX)
      .setGridColor(to: Color(white: 1.0, opacity: 0.15))
      .setShowGridXLines(to: properties.gridXEnable)
      .setShowGridYLines(to: properties.gridYEnable)
      .gridXIndexes(viewModel.candleGridXIndexes)
      .gridYIndexes(viewModel.candleGridYIndexes)
      .setLineWidth(width: 2)
      .setBodyWidth(width: 6)
      .setNegative(
        colorGradient: ColorGradient(Colors.error.swiftUIColor)
      )
      .setPositive(
        colorGradient: ColorGradient(Colors.green.swiftUIColor)
      )
      .chartStyle(
        ChartStyle(
          backgroundColor: .clear,
          foregroundColor: [ColorGradient(Colors.primary.swiftUIColor)]
        )
      ).environmentObject(candleChartValue)
  }
  
  var chartView: some View {
    ZStack {
      switch viewModel.chartOption {
        case .line:
          lineChartView
        case .candlestick:
          candlestickView
      }
    }
  }
  
  var filterView: some View {
    HStack(spacing: 4, content: {
      ForEach(viewModel.options) { option in
        Button(option.title) {
          viewModel.setFilterOption(option)
        }
        .padding(EdgeInsets(top: 9, leading: 12, bottom: 9, trailing: 12))
        .background(
          viewModel.filterOption == option
          ? Colors.primary.swiftUIColor
          : Colors.secondaryBackground.swiftUIColor
        )
        .foregroundColor(
          viewModel.filterOption == option
          ? Colors.contrast.swiftUIColor
          : Colors.whiteText.swiftUIColor
        )
        .cornerRadius(16)
      }
      .font(Fonts.regular.swiftUIFont(size: Constants.FontSize.ultraSmall.value))
      switchButton
    })
    .frame(height: 32)
  }
  
  var switchButton: some View {
    Button {
      viewModel.switchNextChart()
    } label: {
      ZStack {
        Circle()
          .fill(Colors.darkText.swiftUIColor)
          .frame(32)
        
        if viewModel.chartOption == .candlestick {
          GenImages.CommonImages.candleStick.swiftUIImage
            .foregroundColor(Colors.primary.swiftUIColor)
        } else if viewModel.chartOption == .line {
          GenImages.CommonImages.lineChart.swiftUIImage
            .foregroundColor(Colors.primary.swiftUIColor)
        }
      }
    }
  }
}

public extension CryptoChartView {
  func setHighlightValueEnable(_ enable: Bool) -> Self {
    properties.highlightValueEnable = enable
    return self
  }
  
  func setSelectedHistoricalPriceSubject(_ subject: CurrentValueSubject<HistoricalPriceModel?, Never>) -> Self {
    properties.selectedHistoricalPriceSubject = subject
    return self
  }
  
  func highlightHistoricalModel(content: @escaping (HistoricalPriceModel?) -> Void) -> CryptoChartView
  {
    viewModel.highlightHistoricalModel(content: content)
    return self
  }
  
  func setGridXEnable(_ enable: Bool) -> Self {
    properties.gridXEnable = enable
    return self
  }
  
  func setGridYEnable(_ enable: Bool) -> Self {
    properties.gridYEnable = enable
    return self
  }
}
