import DatadogLogs
import SwiftyBeaver
import LFUtilities

class DataDogLogDestination: BaseDestination {
  private lazy var logger: LoggerProtocol = {
    let logger = Logger.create(
      with: Logger.Configuration(
        service: "liquidity.datadog.destination",
        name: LFUtilities.appName,
        networkInfoEnabled: true,
        remoteLogThreshold: .info,
        consoleLogFormat: .shortWith(prefix: "[iOS App] ")
      )
    )
    return logger
  }()

  override public var defaultHashValue: Int { 100 }

  override func send(_ level: SwiftyBeaver.Level, msg: String, thread: String, file: String, function: String, line: Int, context: Any? = nil) -> String? {
    switch level {
    case .verbose:
      logger.notice(msg)
    case .debug:
      logger.debug(msg)
    case .info:
      logger.info(msg)
    case .warning:
      logger.warn(msg)
    case .error:
      logger.error(msg)
    }
    return super.send(level, msg: msg, thread: thread, file: file, function: function, line: line)
  }
}
