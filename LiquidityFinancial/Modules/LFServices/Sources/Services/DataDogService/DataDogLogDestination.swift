import DatadogLogs
import SwiftyBeaver
import LFUtilities
import UIKit

class DataDogLogDestination: BaseDestination {
  private lazy var logger: LoggerProtocol = {
    let ddLogger = Logger.create(
        with: Logger.Configuration(
            name: "ios-liquidity-logger-new-\(LFUtilities.target?.rawValue.lowercased() ?? "")",
            networkInfoEnabled: true,
            remoteLogThreshold: .info
        )
    )

    ddLogger.addAttribute(forKey: "device-model", value: UIDevice.current.model)

    #if DEBUG
    ddLogger.addTag(withKey: "build_configuration", value: "debug")
    #else
    ddLogger.addTag(withKey: "build_configuration", value: "release")
    #endif
    return ddLogger
  }()

  public override var defaultHashValue: Int { 100 }

  override func send(_ level: SwiftyBeaver.Level, msg: String, thread: String, file: String, function: String, line: Int, context: Any? = nil) -> String? {
    switch level {
    case .verbose:
      logger.notice(msg, attributes: ["[FILE]": file, "[FUNCTION]": function, "[LINE]": line])
    case .debug:
      logger.debug(msg, attributes: ["[FILE]": file, "[FUNCTION]": function, "[LINE]": line])
    case .info:
      logger.info(msg, attributes: ["[FILE]": file, "[FUNCTION]": function, "[LINE]": line])
    case .warning:
      logger.warn(msg, attributes: ["[FILE]": file, "[FUNCTION]": function, "[LINE]": line])
    case .error:
      logger.error(msg, attributes: ["[FILE]": file, "[FUNCTION]": function, "[LINE]": line])
    default:
      logger.critical(msg, attributes: ["[FILE]": file, "[FUNCTION]": function, "[LINE]": line])
    }
    return super.send(level, msg: msg, thread: thread, file: file, function: function, line: line)
  }
}
