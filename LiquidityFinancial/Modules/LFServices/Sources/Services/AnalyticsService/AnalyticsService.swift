import Foundation
import LFUtilities
import Factory

extension Container {
  public var analyticsService: Factory<AnalyticsServiceProtocol> {
    self {
      let analytics = AnalyticsService()
      analytics.addTransport(SegmentTransport())
      analytics.addTransport(DataDogTransport())
      return analytics
    }.singleton
  }
}

// MARK: - AnalyticsServiceProtocol

public protocol AnalyticsServiceProtocol {
  func addTransport(_ transport: AnalyticsTransportProtocol)
  func track(event: EventType)
  func track(screen: String, appear: Bool)
  func set(params: [String: Any])
  func flush(force: Bool)
}

// MARK: - AnalyticsService

public class AnalyticsService {
  private let analyticsQueue = DispatchQueue(label: "com.liquidity.analyticsService")
  
  private var services = [AnalyticsTransportProtocol]()
}

// MARK: AnalyticsServiceProtocol
extension AnalyticsService: AnalyticsServiceProtocol {
  public func addTransport(_ transport: AnalyticsTransportProtocol) {
    analyticsQueue.async {
      self.services.append(transport)
    }
  }
  
  public func track(screen: String, appear: Bool) {
    analyticsQueue.async {
      log.info("Track Screen: \(screen), visible: \(appear), logType: \(LogType.navigation)")
      for transport in self.services {
        transport.track(screen: screen, appear: appear)
      }
    }
  }
  
  public func track(event: EventType) {
    analyticsQueue.async {
      log.info("Track: \(event), logType: \(LogType.analytics)")
      for transport in self.services {
        transport.track(event: event)
      }
    }
  }
  
  public func set(params: [String: Any]) {
    analyticsQueue.async {
      log.info("update param: \(params), logType: \(LogType.analytics)")
      for service in self.services {
        service.set(params: params)
      }
    }
  }
  
  public func flush(force: Bool) {
    analyticsQueue.async {
      log.info("flush.")
      for service in self.services {
        log.info("Flushing Service: \(service), logType: \(LogType.analytics)")
        service.flush(force: force)
      }
    }
  }
}
