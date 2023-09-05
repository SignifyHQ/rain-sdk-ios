import Alamofire
import Combine
import Foundation
import SwiftUI
import Factory
import CryptoChartData
import CryptoChartDomain
import LFUtilities

@MainActor
class CryptoChartViewModel: ObservableObject {
  @LazyInjected(\.marketManager) var marketManager
  @LazyInjected(\.cryptoChartRepository) var cryptoChartRepository

  @Published var filterOption = CryptoFilterOption.live
  @Published var chartOption = ChartOption.line
  
  @Published var lineChartData = [(Double, Double)]()
  @Published var lineChartRangeX: ClosedRange<FloatLiteralType> = 0 ... 1
  @Published var lineChartRangeY: ClosedRange<FloatLiteralType> = 0 ... 1
  
  @Published var candleChartData = [CandleData]()
  @Published var candleChartRangeX: ClosedRange<FloatLiteralType> = 0 ... 1
  @Published var candleChartRangeY: ClosedRange<FloatLiteralType> = 0 ... 1
  
  @Published var lineGridXIndexes = [(String, Double)]()
  @Published var lineGridYIndexes = [(String, Double)]()
  
  @Published var candleGridXIndexes = [(String, Double)]()
  @Published var candleGridYIndexes = [(String, Double)]()
  
  var filterOptionSubject = CurrentValueSubject<CryptoFilterOption, Never>(.live)
  var chartOptionSubject = CurrentValueSubject<ChartOption, Never>(.line)
  let candleHistoricalPricesSubject = CurrentValueSubject<[HistoricalPriceModel], Never>([])
  let historicalPricesSubject = CurrentValueSubject<[HistoricalPriceModel], Never>([])
  
  var selectedHistoricalPriceSubject = CurrentValueSubject<HistoricalPriceModel?, Never>(nil)
  
  private var subscribers: Set<AnyCancellable> = []
  private static let extendScale: CGFloat = 0.1
  
  init(
    filterOptionSubject: CurrentValueSubject<CryptoFilterOption, Never>,
    chartOptionSubject: CurrentValueSubject<ChartOption, Never>
  ) {
    self.filterOptionSubject = filterOptionSubject
    self.chartOptionSubject = chartOptionSubject
    fetchCryptoChartData()
  }
  
  var title: String {
    filterOption.title
  }
  
  var options: [CryptoFilterOption] {
    CryptoFilterOption.allCases
  }
}

// MARK: - API
extension CryptoChartViewModel {
  func fetchCryptoChartData() {
    Task {
      do {
        try await marketManager.fetchData()
      } catch {
      }
    }
  }
}

extension CryptoChartViewModel {
  func switchNextChart() {
    switch chartOption {
    case .candlestick:
      chartOption = .line
      chartOptionSubject.send(.line)
    case .line:
      chartOptionSubject.send(.candlestick)
      chartOption = .candlestick
    }
  }
  
  func setFilterOption(_ option: CryptoFilterOption) {
    filterOptionSubject.send(option)
  }
  
  func highlightHistoricalModel(content: @escaping (HistoricalPriceModel?) -> Void) {
    selectedHistoricalPriceSubject.sink(receiveValue: content).store(in: &subscribers)
  }
  
  func setUp(lineChartValue: ChartValue, candleChartValue: ChartValue) {
    lineChartValue.$index
      .removeDuplicates()
      .combineLatest($chartOption, historicalPricesSubject)
      .sink(receiveValue: { [weak self] index, option, models in
        guard let self = self, option == .line else {
          return
        }
        guard index >= 0, index < models.count else {
          self.selectedHistoricalPriceSubject.send(nil)
          return
        }
        self.selectedHistoricalPriceSubject.send(models[index])
      })
      .store(in: &subscribers)
    
    candleChartValue.$index
      .removeDuplicates()
      .combineLatest($chartOption, candleHistoricalPricesSubject)
      .sink(receiveValue: { [weak self] index, option, models in
        guard let self = self, option == .candlestick else {
          return
        }
        guard index >= 0, index < models.count else {
          self.selectedHistoricalPriceSubject.send(nil)
          return
        }
        self.selectedHistoricalPriceSubject.send(models[index])
      })
      .store(in: &subscribers)
  }
  
  func disconnectSocket() {
    marketManager.disconnectSocket()
  }
  
  func appearOperations() {
    Publishers.CombineLatest3(
      $filterOption,
      marketManager
        .lineModelsSubject,
      marketManager
        .liveLineModelsSubject
    )
    .compactMap(compactMapToHistoricalPrices)
    .receive(on: DispatchQueue.main)
    .sink(receiveValue: { [weak self] models in
      self?.historicalPricesSubject.send(models)
    })
    .store(in: &subscribers)
    
    Publishers.CombineLatest3(
      $filterOption,
      marketManager
        .candleModelsSubject,
      marketManager
        .liveCandleModelsSubject
    )
    .compactMap(compactMapToHistoricalPrices)
    .receive(on: DispatchQueue.main)
    .sink(receiveValue: { [weak self] models in
      self?.candleHistoricalPricesSubject.send(models)
    })
    .store(in: &subscribers)
    
    lineHistoricalSubscribe()
    lineLiveSubscribe()
    candleHistoricalSubscribe()
    candleLiveSubscribe()
    
    $candleChartRangeY.map { range in
      range.toIndexes()
    }
    .assign(to: \.candleGridYIndexes, on: self)
    .store(in: &subscribers)
    
    $lineChartRangeY.map { range in
      range.toIndexes()
    }
    .assign(to: \.lineGridYIndexes, on: self)
    .store(in: &subscribers)
    
    filterOptionSubject.receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] option in
      self?.filterOption = option
    }).store(in: &subscribers)
    chartOptionSubject.receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] option in
      self?.chartOption = option
    }).store(in: &subscribers)
  }
}

// MARK: - Private Extension
private extension CryptoChartViewModel {
  func lineHistoricalSubscribe() {
    Publishers.CombineLatest($filterOption, marketManager.lineDatasSubject)
      .compactMap { option, map in
        option == .live ? nil : map[option]
      }
      .assign(to: \.lineChartData, on: self)
      .store(in: &subscribers)
    
    Publishers.CombineLatest($filterOption, marketManager.lineRangeYSubject)
      .compactMap { option, map in
        guard option != .live, let data = map[option] else {
          return nil
        }
        let duration = (data.upperBound - data.lowerBound) * CryptoChartViewModel.extendScale
        let range = (data.lowerBound - duration) ... (data.upperBound + duration)
        return range
      }
      .assign(to: \.lineChartRangeY, on: self)
      .store(in: &subscribers)
    
    Publishers.CombineLatest($filterOption, marketManager.lineRangeXSubject)
      .compactMap { option, map in
        if option == .live {
          return nil
        }
        return map[option]
      }
      .assign(to: \.lineGridXIndexes, on: self)
      .store(in: &subscribers)
    
    Publishers.CombineLatest3($filterOption, $chartOption, marketManager.lineRangeYSubject)
      .compactMap { filterOption, chartOption, map in
        guard filterOption != .live, chartOption == .line, let data = map[filterOption] else {
          return nil
        }
        let duration = (data.upperBound - data.lowerBound) * CryptoChartViewModel.extendScale
        let range = (data.lowerBound - duration) ... (data.upperBound + duration)
        return range
      }
      .assign(to: \.lineChartRangeY, on: self)
      .store(in: &subscribers)
  }
  
  func candleHistoricalSubscribe() {
    Publishers.CombineLatest3($filterOption, $chartOption, marketManager.candleDatasSubject)
      .compactMap { filterOption, chartOption, map in
        guard chartOption == .candlestick, filterOption != .live else {
          return nil
        }
        return map[filterOption]
      }
      .assign(to: \.candleChartData, on: self)
      .store(in: &subscribers)
    
    Publishers.CombineLatest3($filterOption, $chartOption, marketManager.candleRangeXSubject)
      .compactMap { filterOption, chartOption, map in
        guard filterOption != .live, chartOption == .candlestick, let data = map[filterOption] else {
          return nil
        }
        return data
      }
      .assign(to: \.candleGridXIndexes, on: self)
      .store(in: &subscribers)
    
    Publishers.CombineLatest3($filterOption, $chartOption, marketManager.candleRangeYSubject)
      .compactMap { filterOption, chartOption, map in
        guard filterOption != .live, chartOption == .candlestick else {
          return nil
        }
        guard let data = map[filterOption] else {
          return nil
        }
        let duration = (data.upperBound - data.lowerBound) * CryptoChartViewModel.extendScale
        let range = (data.lowerBound - duration) ... (data.upperBound + duration)
        
        return range
      }
      .assign(to: \.candleChartRangeY, on: self)
      .store(in: &subscribers)
  }
  
  func candleLiveSubscribe() {
    Publishers.CombineLatest3($filterOption, $chartOption, marketManager.liveCandleDatasSubject)
      .compactMap { filterOption, chartOption, data in
        guard chartOption == .candlestick, filterOption == .live else {
          return nil
        }
        return data
      }
      .receive(on: DispatchQueue.main)
      .assign(to: \.candleChartData, on: self)
      .store(in: &subscribers)
    
    Publishers.CombineLatest3(
      $filterOption,
      $chartOption,
      marketManager.liveCandleRangeXSubject
    )
    .compactMap { filterOption, chartOption, data in
      guard filterOption == .live, chartOption == .candlestick else {
        return nil
      }
      return data
    }
    .receive(on: DispatchQueue.main)
    .assign(to: \.candleGridXIndexes, on: self)
    .store(in: &subscribers)
    
    Publishers.CombineLatest3(
      $filterOption,
      $chartOption,
      marketManager.liveCandleRangeYSubject
    )
    .compactMap { filterOption, chartOption, data in
      guard filterOption == .live, chartOption == .candlestick else {
        return nil
      }
      let duration = (data.upperBound - data.lowerBound) * CryptoChartViewModel.extendScale
      let range = (data.lowerBound - duration) ... (data.upperBound + duration)
      
      return range
    }
    .receive(on: DispatchQueue.main)
    .assign(to: \.candleChartRangeY, on: self)
    .store(in: &subscribers)
  }
  
  func lineLiveSubscribe() {
    Publishers.CombineLatest($filterOption, marketManager.liveDatasSubject)
      .compactMap { option, datas in
        option != .live ? nil : datas
      }
      .receive(on: DispatchQueue.main)
      .assign(to: \.lineChartData, on: self)
      .store(in: &subscribers)
    
    Publishers.CombineLatest($filterOption, marketManager.liveRangeYSubject)
      .compactMap { option, data in
        if option != .live {
          return nil
        }
        let duration = (data.upperBound - data.lowerBound) * CryptoChartViewModel.extendScale
        let range = (data.lowerBound - duration) ... (data.upperBound + duration)
        return range
      }
      .receive(on: DispatchQueue.main)
      .assign(to: \.lineChartRangeY, on: self)
      .store(in: &subscribers)
    
    Publishers.CombineLatest($filterOption, marketManager.liveRangeXSubject)
      .compactMap { option, data in
        option != .live ? nil : data
      }
      .receive(on: DispatchQueue.main)
      .assign(to: \.lineGridXIndexes, on: self)
      .store(in: &subscribers)
    
    Publishers.CombineLatest3($filterOption, $chartOption, marketManager.liveRangeYSubject)
      .compactMap { filterOption, chartOption, data in
        guard filterOption == .live, chartOption == .line else {
          return nil
        }
        let duration = (data.upperBound - data.lowerBound) * CryptoChartViewModel.extendScale
        let range = (data.lowerBound - duration) ... (data.upperBound + duration)
        return range
      }
      .receive(on: DispatchQueue.main)
      .assign(to: \.lineChartRangeY, on: self)
      .store(in: &subscribers)
  }
  
  func compactMapToHistoricalPrices(
    option: CryptoFilterOption,
    models: [CryptoFilterOption: [HistoricalPriceModel]],
    liveModels: [HistoricalPriceModel]
  ) -> [HistoricalPriceModel]? {
    if option == .live {
      return liveModels
    }
    return models[option]
  }
}
