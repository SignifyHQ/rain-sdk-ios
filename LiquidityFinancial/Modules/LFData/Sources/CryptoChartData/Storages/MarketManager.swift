import Foundation
import Combine
import LFLocalizable
import Factory
import LFUtilities
import CryptoChartDomain
import AuthorizationManager
import NetworkUtilities
import EnvironmentService

public class MarketManager {
  var networkEnvironment: NetworkEnvironment {
    get {
      environmentService.networkEnvironment
    }
    set {
      environmentService.networkEnvironment = newValue
    }
  }
  
  @LazyInjected(\.environmentService) var environmentService
  
  @LazyInjected(\.cryptoChartRepository) var cryptoChartRepository
  @LazyInjected(\.authorizationManager) var authorizationManager
  
    // MARK: - LineChart Subjects
  public let lineModelsSubject = CurrentValueSubject<[CryptoFilterOption: [HistoricalPriceModel]], Never>([:])
  public let lineDatasSubject = CurrentValueSubject<[CryptoFilterOption: [(Double, Double)]], Never>([:])
  public let lineRangeYSubject = CurrentValueSubject<[CryptoFilterOption: ClosedRange<FloatLiteralType>], Never>([:])
  public let lineRangeXSubject = CurrentValueSubject<[CryptoFilterOption: [(String, Double)]], Never>([:])
  
  public let liveLineModelsSubject = CurrentValueSubject<[HistoricalPriceModel], Never>([])
  public let liveDatasSubject = CurrentValueSubject<[(Double, Double)], Never>([])
  public let liveRangeYSubject = CurrentValueSubject<ClosedRange<FloatLiteralType>, Never>(0 ... 1)
  public let liveRangeXSubject = CurrentValueSubject<[(String, Double)], Never>([])
  
    // MARK: - CandleChart Subjects
  public let candleModelsSubject = CurrentValueSubject<[CryptoFilterOption: [HistoricalPriceModel]], Never>([:])
  public let candleDatasSubject = CurrentValueSubject<[CryptoFilterOption: [CandleData]], Never>([:])
  public let candleRangeYSubject = CurrentValueSubject<[CryptoFilterOption: ClosedRange<FloatLiteralType>], Never>([:])
  public let candleRangeXSubject = CurrentValueSubject<[CryptoFilterOption: [(String, Double)]], Never>([:])
  
  public let liveCandleModelsSubject = CurrentValueSubject<[HistoricalPriceModel], Never>([])
  public let liveCandleDatasSubject = CurrentValueSubject<[CandleData], Never>([])
  public let liveCandleRangeYSubject = CurrentValueSubject<ClosedRange<FloatLiteralType>, Never>(0 ... 1)
  public let liveCandleRangeXSubject = CurrentValueSubject<[(String, Double)], Never>([])
  
  let pingSocketTimer = Timer.publish(every: 30, on: .main, in: .common)
    .autoconnect()
  var websocketTask: URLSessionWebSocketTask?
  private var subscribers: Set<AnyCancellable> = []
  
  public init() {
    Task {
      do {
        try await fetchData()
      } catch {}
    }
  }
}

public extension MarketManager {
  func disconnectSocket() {
    pingSocketTimer.upstream.connect().cancel()
  }
  
  func fetchData() async throws {
    let models = try await cryptoChartRepository.getCMCSymbolHistories(
      symbol: LFUtilities.cryptoCurrency.uppercased(),
      period: CryptoFilterOption.live.interval
    )
    let historicalModels = HistoricalPriceModel.map(entities: models)
    guard !historicalModels.isEmpty else {
      self.startPriceWebsocket()
      return
    }
    let count = min(60, historicalModels.count)
    let trimModels = Array(historicalModels[(historicalModels.count - count) ..< historicalModels.count])
    
    var lineDatas = [(Double, Double)]()
    var minValue: Double?
    var maxValue: Double?
    
    for model in trimModels {
      guard let value = model.close else { continue }
      if let minValueUnwrapped = minValue {
        minValue = min(minValueUnwrapped, value)
      } else {
        minValue = value
      }
      if let maxValueUnwrapped = maxValue {
        maxValue = max(maxValueUnwrapped, value)
      } else {
        maxValue = value
      }
      let xValue = Double(lineDatas.count)
      lineDatas.append((xValue, value))
    }
    
    if !lineDatas.isEmpty, let minValue = minValue, let maxValue = maxValue {
      let lineRangeY = minValue ... maxValue
      
      self.liveDatasSubject.send(lineDatas)
      self.liveRangeYSubject.send(lineRangeY)
    }
    self.liveRangeXSubject.send(trimModels.getGridXIndexes(option: .live))
    self.liveLineModelsSubject.send(trimModels)
    
    let candleDatas = trimModels.toCandleDatas()
    
    self.liveCandleDatasSubject.send(candleDatas)
    self.liveCandleRangeXSubject.send(trimModels.getGridXIndexes(option: .live))
    self.liveCandleRangeYSubject.send(candleDatas.rangeY())
    self.liveCandleModelsSubject.send(trimModels)
    
    self.startPriceWebsocket()
    let filterOptions: [CryptoFilterOption] = [.day, .week, .month, .year, .all]
    filterOptions.forEach { option in
      fetchCMCSymbolHistories(option: option)
    }
  }
}

// MARK: - CMCSymbolHistories Handles
private extension MarketManager {
  func fetchCMCSymbolHistories(option: CryptoFilterOption) {
    Task {
      do {
        let models = try await self.cryptoChartRepository.getCMCSymbolHistories(
          symbol: LFUtilities.cryptoCurrency.uppercased(),
          period: option.interval
        )
        let historicalModels = HistoricalPriceModel.map(entities: models)
        guard !historicalModels.isEmpty else {
          return
        }
        handleCMCSymbolForLineChart(historicalModels: historicalModels, option: option)
        handleCMCSymbolForCandleChart(historicalModels: historicalModels, option: option)
      } catch {
      }
    }
  }
  
  func handleCMCSymbolForLineChart(historicalModels: [HistoricalPriceModel], option: CryptoFilterOption) {
    var lineModels = [HistoricalPriceModel]()
    var lineDatas = [(Double, Double)]()
    var minValue: Double!
    var maxValue: Double!
    
    for model in historicalModels {
      guard let value = model.close else {
        continue
      }
      minValue = minValue == nil ? value : min(minValue, value)
      maxValue = maxValue == nil ? value : max(maxValue, value)
      
      let xValue = Double(lineDatas.count)
      lineDatas.append((xValue, value))
      lineModels.append(model)
    }
    
    if !lineDatas.isEmpty, let minValue = minValue, let maxValue = maxValue {
      let lineRangeY = minValue ... maxValue
      
      var newModelData = self.lineModelsSubject.value
      newModelData[option] = lineModels
      self.lineModelsSubject.send(newModelData)
      
      var newLineData = self.lineDatasSubject.value
      newLineData[option] = lineDatas
      self.lineDatasSubject.send(newLineData)
      
      var rangeYData = self.lineRangeYSubject.value
      rangeYData[option] = lineRangeY
      self.lineRangeYSubject.send(rangeYData)
    }
    var rangeXData = self.lineRangeXSubject.value
    rangeXData[option] = historicalModels.getGridXIndexes(option: option)
    self.lineRangeXSubject.send(rangeXData)
  }
  
  func handleCMCSymbolForCandleChart(historicalModels: [HistoricalPriceModel], option: CryptoFilterOption) {
    let trimModels = self.wrapCandleModels(historicalModels)
    let candleDatas = trimModels.toCandleDatas()
    
    var candleModel = self.candleModelsSubject.value
    candleModel[option] = trimModels
    self.candleModelsSubject.send(candleModel)
    
    var candleData = self.candleDatasSubject.value
    candleData[option] = candleDatas
    self.candleDatasSubject.send(candleData)
    
    var candleRangeYCache = self.candleRangeYSubject.value
    candleRangeYCache[option] = candleDatas.rangeY()
    self.candleRangeYSubject.send(candleRangeYCache)
    
    var candleRangeXCache = self.candleRangeXSubject.value
    candleRangeXCache[option] = trimModels.getGridXIndexes(option: option)
    self.candleRangeXSubject.send(candleRangeXCache)
  }
}

// MARK: - Websocket Handles
private extension MarketManager {
  func startPriceWebsocket() {
    var hostUrlString = APIConstants.socketProdHost
    switch networkEnvironment {
    case .productionLive: hostUrlString = APIConstants.socketProdHost
    case .productionTest: hostUrlString = APIConstants.socketDevHost
    }
    guard let url = URL(string: "\(hostUrlString)/ws/cmc/\(LFUtilities.cryptoCurrency)/live") else {
      return
    }
    websocketTask = connectSocket(url: url)
    receivePriceMessage()
    sendPingWebsocket()
  }
  
  func sendPingWebsocket() {
    pingSocketTimer.prepend(Date())
      .sink(receiveValue: { [weak self] _ in
        self?.websocketTask?.sendPing(pongReceiveHandler: { error in
          if let error = error {
            log.error("Websocket pong receive \(error.localizedDescription)")
          } else {
            log.info("Websocket ping success")
          }
        })
      })
      .store(in: &subscribers)
  }
  
  func connectSocket(url: URL) -> URLSessionWebSocketTask? {
    var request = URLRequest(url: url)
    if let token = authorizationManager.fetchTokens() {
      request.setValue("Bearer \(token.accessToken)", forHTTPHeaderField: "Authorization")
      request.addValue("application/json", forHTTPHeaderField: "Content-Type")
      request.addValue("application/json", forHTTPHeaderField: "Accept")
    }
    let webSocketTask = URLSession.shared.webSocketTask(with: request)
    webSocketTask.resume()
    return webSocketTask
  }
  
  func receivePriceMessage() {
    websocketTask?.receive { [weak self] result in
      guard let self = self else { return }
      defer { self.receivePriceMessage() }
      switch result {
      case let .failure(error):
        log.debug("Websocket receiving message: \(error)")
      case let .success(message):
        let model: HistoricalPriceModel?
        switch message {
        case let .string(text):
          model = HistoricalPriceModel.generateHistoricalPriceModel(message: text)
        case let .data(data):
          model = HistoricalPriceModel.generateHistoricalPriceModel(data: data)
        @unknown default:
          model = nil
        }
        guard let model = model else { return }
        handlePriceValueForLineChart(priceModel: model)
        handlePriceValueForCandleChart(priceModel: model)
      }
    }
  }
  
  func handlePriceValueForLineChart(priceModel: HistoricalPriceModel) {
    var newPrices = self.liveLineModelsSubject.value
    if let lastValue = newPrices.last,
       let lastOpenTime = lastValue.timeOpen?.convertTimestampToDouble(dateFormat: Constants.DateFormat.iso8601WithTimeZone.rawValue) {
      if lastOpenTime > priceModel.timeOpen?.convertTimestampToDouble(
        dateFormat: Constants.DateFormat.iso8601WithTimeZone.rawValue
      ) ?? 0 {
        return
      }
    }
    
    newPrices.append(priceModel)
    self.liveLineModelsSubject.send(newPrices)
    
    if let value = priceModel.close {
      var newDatas = self.liveDatasSubject.value
      let xValue = Double(newDatas.count)
      newDatas.append((xValue, value))
      self.liveDatasSubject.send(newDatas)
      
      var rangeY = self.liveRangeYSubject.value
      if rangeY.lowerBound > value || rangeY.upperBound < value {
        rangeY = min(rangeY.lowerBound, value) ... max(rangeY.upperBound, value)
        self.liveRangeYSubject.send(rangeY)
      }
    }
    self.liveRangeXSubject.send(newPrices.getGridXIndexes(option: .live))
  }
  
  func handlePriceValueForCandleChart(priceModel: HistoricalPriceModel) {
    var newValue = self.liveCandleModelsSubject.value
    var candleDatas = self.liveCandleDatasSubject.value
    if let lastModel = newValue.last, var lastCandleData = candleDatas.last {
      let openTimeValue = priceModel.timeOpen?.convertTimestampToDouble(
        dateFormat: Constants.DateFormat.iso8601WithTimeZone.rawValue
      ) ?? 0
      let lastTimeValue = lastModel.lastUpdated?.convertTimestampToDouble(
        dateFormat: Constants.DateFormat.iso8601WithTimeZone.rawValue
      ) ?? 0
      if openTimeValue <= lastTimeValue {
        newValue.removeLast()
        candleDatas.removeLast()
      } else {
        newValue.removeLast()
        candleDatas.removeLast()
        lastCandleData.close = priceModel.open ?? lastCandleData.close
        
        newValue.append(lastModel)
        candleDatas.append(lastCandleData)
      }
    }
    newValue.append(priceModel)
    
    self.liveCandleModelsSubject.send(newValue)
    self.liveCandleDatasSubject.send(candleDatas)
    self.liveCandleRangeXSubject.send(newValue.getGridXIndexes(option: .live))
    self.liveCandleRangeYSubject.send(candleDatas.rangeY())
  }
  
  // swiftlint:disable function_body_length
  func wrapCandleModels(_ models: [HistoricalPriceModel]) -> [HistoricalPriceModel] {
    let maximumCandleCount = 40
    if models.count <= maximumCandleCount {
      return models
    }
    let range = models.count / maximumCandleCount
    var resultModels = [HistoricalPriceModel]()
    
    for index in 0 ..< maximumCandleCount {
      let startIndex = index * range
      let endIndex = (index == maximumCandleCount - 1) ? models.count - 1 : index * range + range - 1
      let startModel = models[startIndex]
      let endModel = models[endIndex]
      
      let rangeModels = Array(models[startIndex ... endIndex])
      var rangeLow = startModel.low
      var rangeHigh = startModel.high
      var value = 0.0
      var valueCount: Double = 0
      var volume: Double = 0
      
      for model in rangeModels {
        guard let high = model.high,
              let low = model.low
        else {
          continue
        }
        
        if let rangeLowValue = rangeLow {
          if rangeLowValue > low {
            rangeLow = low
          }
        } else {
          rangeLow = low
        }
        
        if let rangeHighValue = rangeHigh {
          if rangeHighValue < high {
            rangeHigh = high
          }
        } else {
          rangeHigh = high
        }
        
        value += model.close ?? 0.0
        valueCount += 1
        
        if let volumeString = model.volume {
          volume += volumeString
        }
      }
      if valueCount > 0 {
        value /= valueCount
      }
      
      let startTimeStamp = startModel.timestamp ?? startModel.lastUpdated?.convertTimestampToDouble(
        dateFormat: Constants.DateFormat.iso8601WithTimeZone.rawValue
      ) ?? 0
      let endTimeStamp = endModel.timestamp ?? startModel.lastUpdated?.convertTimestampToDouble(
        dateFormat: Constants.DateFormat.iso8601WithTimeZone.rawValue
      ) ?? 0
      let timestamp = (startTimeStamp + endTimeStamp) / 2
      
      let candleModel = HistoricalPriceModel(
        currency: startModel.currency,
        interval: startModel.interval,
        timestamp: timestamp,
        changePercentage: startModel.changePercentage,
        timeOpen: startModel.timeOpen,
        timeHigh: startModel.timeHigh,
        timeLow: startModel.timeLow,
        lastUpdated: endModel.lastUpdated,
        open: startModel.open,
        close: endModel.close,
        high: rangeHigh,
        low: max(rangeLow ?? 0.0, 0.0),
        value: value,
        volume: volume
      )
      resultModels.append(candleModel)
    }
    return resultModels
  }
  // swiftlint:enable function_body_length
}
