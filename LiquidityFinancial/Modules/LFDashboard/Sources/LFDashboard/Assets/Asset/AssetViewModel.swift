import Foundation

@MainActor
class AssetViewModel: ObservableObject {
  @Published var cryptoBalance: String = "0.00"
  @Published var usdBalance: String = "0.00"
  @Published var loading: Bool = false

  @Published var cryptoPrice: String = "0.00"
  @Published var changePercent: Double = 0
  @Published var showCryptoDetail: Bool = false

  var isPositivePrice: Bool {
    changePercent > 0
  }

  var changePercentAbsString: String {
    String(format: "%.2f%%", abs(changePercent))
  }
}
