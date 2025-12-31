import Combine
import SwiftUI
import CryptoChartData

public class CryptoChartProperties: ObservableObject {
  @Published var highlightValueEnable: Bool = true
  @Published var selectedHistoricalPriceSubject = CurrentValueSubject<HistoricalPriceModel?, Never>(nil)
  @Published var gridXEnable: Bool = true
  @Published var gridYEnable: Bool = true
}
